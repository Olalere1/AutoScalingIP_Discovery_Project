locals {
  name = "auto-discovery-mono-app"

  cert-arn            = "arn:aws:acm:eu-west-1:913454847504:certificate/2947f91f-2e1e-4291-8603-15daa2862ab8"
  jenkins-public-ip   = "63.33.69.12"
  jenkins-sg-id       = "sg-022e6c581480fa354"
  private-subnet-id-1 = "subnet-0fa1ca9b28686406b"
  private-subnet-id-2 = "subnet-0535717d598a522f0"
  private-subnet-id-3 = "subnet-0f25671e30bd7ef8d"
  public-subnet-id-1  = "subnet-017015bc8bb9cd9fb"
  public-subnet-id-2  = "subnet-0bd28ad9540a3763e"
  public-subnet-id-3  = "subnet-005004f01ffc9ea82"
  vault-public-ip     = "54.216.195.200"
  vpc-id              = "vpc-0ccaad2440fbaf71f"

}

# AWS_VPC 
data "aws_vpc" "vpc" {
  id = local.vpc-id
}

data "aws_subnet" "public-subnet-1" {
  id = local.public-subnet-id-1
}

data "aws_subnet" "public-subnet-2" {
  id = local.public-subnet-id-2
}

data "aws_subnet" "public-subnet-3" {
  id = local.public-subnet-id-3
}

data "aws_subnet" "private-subnet-1" {
  id = local.private-subnet-id-1
}

data "aws_subnet" "private-subnet-2" {
  id = local.private-subnet-id-2
}

data "aws_subnet" "private-subnet-3" {
  id = local.private-subnet-id-3
}

data "aws_security_group" "jenkins-sg" {
  id = local.jenkins-sg-id
}

data "aws_acm_certificate" "cert-arn" {
  domain      = var.domain-name
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

# data "aws_security_group" "bastion-sg" {
#   id = local.bastion_sg
# }

module "security-groups" {
  source            = "./modules/security-groups"
  vpc-id            = data.aws_vpc.vpc.id
  allowed-ssh-ips   = var.allowed-ssh-ips
  project-name      = var.project-name
  asg-port          = var.asg-port
  nexus-port-1      = var.nexus-port-1
  nexus-port-2      = var.nexus-port-2
  sonar-port        = var.sonar-port
  rds-port          = var.rds-port
  jenkins-master-sg = data.aws_security_group.jenkins-sg.id
}

module "keypair" {
  source = "./modules/keypair"
}

module "jenkins-servers" {
  source        = "./modules/jenkins-servers"
  redhat-ami-id = var.redhat-ami-id
  ubuntu-ami-id = var.ubuntu-ami-id
  instance-type = var.instance-type
  key-name      = module.keypair.infra-pub-key
  subnet-id     = data.aws_subnet.public-subnet-1.id
  jenkins-sg    = data.aws_security_group.jenkins-sg.id
  nexus-ip      = module.nexus-server.nexus-server-public-ip
  nr-region     = var.nr-region
  nr-acc-id     = var.nr-acc-id
  nr-key        = var.nr-key
}

module "nexus-server" {
  source         = "./modules/nexus-server"
  redhat-ami-id  = var.redhat-ami-id
  public-subnets = [data.aws_subnet.public-subnet-1.id, data.aws_subnet.public-subnet-2.id]
  instance-type  = var.instance-type
  key-name       = module.keypair.infra-pub-key
  subnet-id      = data.aws_subnet.public-subnet-1.id
  nexus-sg-id    = [module.security-groups.nexus-sg-id]
  nr-region      = var.nr-region
  nr-acc-id      = var.nr-acc-id
  nr-key         = var.nr-key
  ssl-cert-id    = data.aws_acm_certificate.cert-arn.arn
}

module "bastion-host" {
  source           = "./modules/bastion-host"
  redhat-ami-id    = var.redhat-ami-id
  instance-type    = var.instance-type
  key-name         = module.keypair.infra-pub-key
  bastion-sg       = [module.security-groups.ansible-bastion-sg-id]
  private-key-name = module.keypair.infra-private-key
  bastion-subnet   = data.aws_subnet.public-subnet-2.id
  nr-key           = var.nr-key
  nr-acc-id        = var.nr-acc-id
  nr-region        = var.nr-region
}

module "ansible-server" {
  source                 = "./modules/ansible-server"
  redhat-ami-id          = var.redhat-ami-id
  instance-type          = var.instance-type
  ssh-key-name           = module.keypair.infra-pub-key
  public-subnet-id       = data.aws_subnet.private-subnet-1.id
  ansible-sg             = module.security-groups.ansible-bastion-sg-id
  stage-playbook         = "${path.root}/modules/ansible-server/stage-playbook.yaml"
  prod-playbook          = "${path.root}/modules/ansible-server/prod-playbook.yaml"
  stage-discovery-script = "${path.root}/modules/ansible-server/stage-autodiscovery.sh"
  prod-discovery-script  = "${path.root}/modules/ansible-server/prod-autodiscovery.sh"
  private-key            = module.keypair.infra-private-key
  nexus-ip               = module.nexus-server.nexus-server-public-ip
  nr-key                 = var.nr-key
  nr-acc-id              = var.nr-acc-id
  nr-region              = var.nr-region
}

data "vault_generic_secret" "db-secret" {
  path = "secret/database"
}

module "rds-database" {
  source       = "./modules/rds-database"
  db-subnet-id = [data.aws_subnet.private-subnet-1.id, data.aws_subnet.private-subnet-2.id, data.aws_subnet.private-subnet-3.id]
  db-name      = var.db-name
  db-username  = data.vault_generic_secret.db-secret.data["username"]
  db-password  = data.vault_generic_secret.db-secret.data["password"]
  vpc-sg-id    = [module.security-groups.rds-sg-id]
}

module "sonarqube-server" {
  source              = "./modules/sonarqube-server"
  ubuntu-ami-id       = var.ubuntu-ami-id
  public-subnets      = [data.aws_subnet.public-subnet-2.id, data.aws_subnet.public-subnet-3.id]
  instance-type       = var.instance-type
  key-name            = module.keypair.infra-pub-key
  subnet-id           = data.aws_subnet.public-subnet-2.id
  sonarqube-sg        = module.security-groups.sonarqube-id
  nr-key              = var.nr-key
  nr-acc-id           = var.nr-acc-id
  nr-region           = var.nr-region
  cert-arn            = data.aws_acm_certificate.cert-arn.arn
  sonar-postgress-pwd = var.sonar-postgress-pwd
  sonar-psqldb-pwd    = var.sonar-psqldb-pwd
}

module "stage-alb" {
  source         = "./modules/stage-alb"
  alb-name-stage = "stage-alb"
  asg-sg         = [module.security-groups.asg-sg-id]
  public-subnets = [data.aws_subnet.public-subnet-1.id, data.aws_subnet.public-subnet-2.id, data.aws_subnet.public-subnet-3.id]
  cert-arn       = data.aws_acm_certificate.cert-arn.arn
  vpc-id         = data.aws_vpc.vpc.id
}

module "prod-alb" {
  source         = "./modules/prod-alb"
  alb-name-prod  = "prod-alb"
  asg-sg         = [module.security-groups.asg-sg-id]
  public-subnets = [data.aws_subnet.public-subnet-1.id, data.aws_subnet.public-subnet-2.id, data.aws_subnet.public-subnet-3.id]
  cert-arn       = data.aws_acm_certificate.cert-arn.arn
  vpc-id         = data.aws_vpc.vpc.id
}

module "records" {
  source                = "./modules/records"
  domain-name           = var.domain-name
  prod-domain-name      = var.prod-domain-name
  prod-dns-name         = module.prod-alb.prod_lb_dns_name
  prod-zone-id          = module.prod-alb.prod_lb_zone_id
  stage-domain-name     = var.stage-domain-name
  stage-dns-name        = module.stage-alb.stage_lb_dns_name
  stage-zone-id         = module.stage-alb.stage_lb_zone_id
  sonarqube-domain-name = var.sonarqube-domain-name
  sonarqube-dns-name    = module.sonarqube-server.sonarqube-lb-dns-name
  sonarqube-zone-id     = module.sonarqube-server.sonarqube-lb-zone-id
  nexus-domain-name     = var.nexus-domain-name
  nexus-dns-name        = module.nexus-server.nexus-lb-dns-name
  nexus-zone-id         = module.nexus-server.nexus-lb-zone-id
}


module "prod-asg" {
  source              = "./modules/prod-asg"
  pub-key             = module.keypair.infra-pub-key
  nexus-ip-prd        = module.nexus-server.nexus-server-public-ip
  nr-acc-id           = var.nr-acc-id
  nr-key              = var.nr-key
  nr-region           = var.nr-region
  asg-prd-name        = "${local.name}-prod-asg"
  vpc-zone-identifier = [data.aws_subnet.private-subnet-2.id, data.aws_subnet.private-subnet-3.id]
  tg-prod             = module.prod-alb.prod-tg-arn
  redhat              = var.redhat-ami-id
  prod-sg             = [module.security-groups.asg-sg-id]
}

module "stage-asg" {
  source              = "./modules/stage-asg"
  pub-key             = module.keypair.infra-pub-key
  nexus-ip-stage      = module.nexus-server.nexus-server-public-ip
  nr-acc-id           = var.nr-acc-id
  nr-key              = var.nr-key
  nr-region           = var.nr-region
  asg-stage-name      = "${local.name}-stage-asg"
  vpc-zone-identifier = [data.aws_subnet.private-subnet-1.id, data.aws_subnet.private-subnet-2.id]
  tg-stage            = module.stage-alb.stage-tg-arn
  redhat              = var.redhat-ami-id
  stage-sg            = [module.security-groups.asg-sg-id]
}