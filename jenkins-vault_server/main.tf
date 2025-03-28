# Provider configuration
locals {
  name = "auto-discovery-mono-app"
}

provider "aws" {
  region  = var.region
  profile = var.profile
}

terraform {
  backend "s3" {
    bucket         = "auto-discovery-mono-app-s3"
    key            = "vault-remote/tfstate"
    dynamodb_table = "auto-discovery-mono-app-dynamodb"
    region         = "eu-west-1"
    profile        = "petproject"
  }
}

################################################################
## Creating a VPC using terraform-aws-modules
module "vpc" {
  #checkov:skip=CKV_TF_2: Tag version number will be enfored on the stage/production environment
  #checkov:skip=CKV_TF_1: commit hashing will be enfored on the stage/production environment
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc-name
  cidr = var.vpc-cidr

  azs                = var.azs
  private_subnets    = var.private-subnets
  public_subnets     = var.public-subnets
  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


# Security group for Vault
resource "aws_security_group" "vault-sg" {
  #checkov:skip=CKV_AWS_260: port is open to allow traffic
  name_prefix = "vault-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for Vault server"

  # Vault API
  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Vault API access"
  }

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed-ssh-ips
    description = "SSH access"
  }
  # Http access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP access"
  }

  # Https access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "vault-security-group"
  }
}

# Creating security group for jenkins
resource "aws_security_group" "jenkins-sg" {
  name        = "${local.name}-jenkins-sg"
  vpc_id      = module.vpc.vpc_id
  description = "security group for jenkins"

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed-ssh-ips
  }
  ingress {
    description = "allow http access"
    from_port   = 32768
    to_port     = 60999
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  dynamic "ingress" {
    for_each = [80, 8080, 443, 4243]
    iterator = port
    content {
      description = "TLS from VPC"
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${local.name}-jenkins-sg"
  }
}


# Create a Key Pair to SSH into EC2 instance
resource "tls_private_key" "vault-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Store the private key locally
resource "local_file" "vault-pri-key" {
  filename        = "vault-pri-key.pem"
  content         = tls_private_key.vault-key.private_key_pem
  file_permission = "600"
}

# Store the public key locally
resource "aws_key_pair" "vault-key-pub" {
  key_name   = "vault-pub-key"
  public_key = tls_private_key.vault-key.public_key_openssh
}

# EC2 instance for Vault
resource "aws_instance" "vault-server" {
  #checkov:skip=CKV_AWS_135: Optimazation will be enfored on the stage/production environment
  #checkov:skip=CKV_AWS_126: detailed monitoring will be enfored on the stage/production environment
  #checkov:skip=CKV_AWS_88: Access  control  will be enfored on the stage/production environment
  ami                         = var.ami-ubuntu
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.vault-key-pub.key_name
  vpc_security_group_ids      = [aws_security_group.vault-sg.id]
  associate_public_ip_address = true
  subnet_id                   = module.vpc.public_subnets[2]
  iam_instance_profile        = aws_iam_instance_profile.vault_kms_profile.id
  user_data = templatefile("./vault_server_script.sh", {
    var2      = aws_kms_key.vault.id,
    var1      = var.region,
    nr-acc-id = var.nr-acc-id,
    nr-key    = var.nr-key,
    nr-region = var.nr-region
  })
  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name = "vault-server"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = "true"
  }
}

# Creating Jenkins Server
resource "aws_instance" "jenkins-server" {
  #checkov:skip=CKV_AWS_135: Optimazation will be enfored on the stage/production environment
  #checkov:skip=CKV_AWS_126: detailed monitoring will be enfored on the stage/production environment
  #checkov:skip=CKV_AWS_88: Access  control  will be enfored on the stage/production environment
  ami                         = var.ami_id
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.vault-key-pub.key_name
  vpc_security_group_ids      = [aws_security_group.jenkins-sg.id]
  associate_public_ip_address = true
  subnet_id                   = module.vpc.public_subnets[0]
  iam_instance_profile        = aws_iam_instance_profile.jenkins-role.id
  user_data                   = local.jenkinscript
  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name = "jenkins-server"
  }

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
    encrypted   = "true"
  }
}

# Creating Jenkins Iam
resource "aws_kms_key" "vault" {
  description             = "Encryption KMS key for vault"
  enable_key_rotation     = true
  deletion_window_in_days = 10
}

resource "aws_elb" "vault-elb" {
  name            = "vault-lb"
  security_groups = [aws_security_group.vault-sg.id]
  subnets         = [module.vpc.public_subnets[2], module.vpc.public_subnets[1]]
  listener {
    instance_port      = 8200
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = aws_acm_certificate.cert.arn
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:8200"
    interval            = 30
  }

  instances                   = [aws_instance.vault-server.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "vault-elb"
  }

}

resource "aws_elb" "jenkins-server-elb" {
  name            = "jenkins-server-elb"
  security_groups = [aws_security_group.jenkins-sg.id]
  subnets         = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]
  listener {
    instance_port      = 8080
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = aws_acm_certificate.cert.arn
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:8080"
    interval            = 30
  }

  instances                   = [aws_instance.jenkins-server.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "jenkins-server-elb"
  }

}


data "aws_route53_zone" "route53-zone" {
  name         = var.domain-name
  private_zone = false
}

resource "aws_route53_record" "vault-record" {
  zone_id = data.aws_route53_zone.route53-zone.zone_id
  name    = var.vault-domain-name
  type    = "A"
  alias {
    name                   = aws_elb.vault-elb.dns_name
    zone_id                = aws_elb.vault-elb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "jenkins-record" {
  zone_id = data.aws_route53_zone.route53-zone.zone_id
  name    = var.jenkins-domain-name
  type    = "A"
  alias {
    name                   = aws_elb.jenkins-server-elb.dns_name
    zone_id                = aws_elb.jenkins-server-elb.zone_id
    evaluate_target_health = true
  }
}

# CREATE CERTIFICATE WHICH IS DEPENDENT ON HAVING A DOMAIN NAME
resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain-name
  subject_alternative_names = [var.domain-names]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# ATTACHING ROUTE53 AND THE CERTFIFCATE- CONNECTING ROUTE 53 TO THE CERTIFICATE
resource "aws_route53_record" "cert-record" {
  for_each = {
    for anybody in aws_acm_certificate.cert.domain_validation_options : anybody.domain_name => {
      name   = anybody.resource_record_name
      record = anybody.resource_record_value
      type   = anybody.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.route53-zone.zone_id
}

# SIGN THE CERTIFICATE
resource "aws_acm_certificate_validation" "sign-cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert-record : record.fqdn]
}
