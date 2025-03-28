resource "aws_instance" "sonarqube_instance" {
  #checkov:skip=CKV_AWS_135: Optimazation will be enfored on the stage/production environment
  #checkov:skip=CKV_AWS_126: detailed monitoring will be enfored on the stage/production environment
  #checkov:skip=CKV_AWS_88: using public ip for testing purposes, it will be enfored on the stage/production environment
  ami                         = var.ubuntu-ami-id
  instance_type               = var.instance-type
  subnet_id                   = var.subnet-id
  key_name                    = var.key-name
  vpc_security_group_ids      = [var.sonarqube-sg]
  associate_public_ip_address = true
  user_data                   = local.sonarqube_user_data

  metadata_options {
    http_tokens = "required"
  }
  root_block_device {
    volume_size = 50
    volume_type = "gp3"
    encrypted   = "true"
  }
  tags = {
    Name = "sonarqube_instance"
  }
}


# Creating the ELB for the SonarQube server
resource "aws_elb" "elb-sonar" {
  name            = "elb-sonar"
  subnets         = var.public-subnets
  security_groups = [var.sonarqube-sg]
  listener {
    instance_port      = 9000
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = var.cert-arn
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:9000"
    interval            = 30
  }

  instances                   = [aws_instance.sonarqube_instance.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "sonar-elb"
  }
}
