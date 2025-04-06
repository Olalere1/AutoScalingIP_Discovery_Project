##########################
# Jenkins-Vault-Server
variable "region" {
  default = "eu-west-1"
}

variable "profile" {
  default = "cbauser_admin"
}
variable "ami-ubuntu" {
  default = "ami-0df368112825f8d8f" #Ubuntu ami for Vault server to be changed to eu-west-1 type
}
variable "domain-name" {
  default = "hullerdata.com"
}
variable "domain-names" {
  default = "*.hullerdata.com"
}
variable "vault-domain-name" {
  default = "vault.hullerdata.com"
}
variable "jenkins-domain-name" {
  default = "jenkins.hullerdata.com"
}
variable "ami_id" {
  default = "ami-09de149defa704528" #Redhat ami for jenkins server to be changed to eu-west-1 type
}

variable "instance_type" {
  default = "t2.medium"
}

##############################
## VPC
variable "vpc-name" {
  description = "The name of the VPC"
  type        = string
  default     = "auto-discovery-vpc"
}

variable "vpc-cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "A list of availability zones in the region"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}
variable "private-subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}
variable "public-subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

###########################
# Securtiy group
variable "allowed-ssh-ips" {
  description = "A list of IP addresses that are allowed to SSH into the Vault server"
  type        = list(string)
  default     = ["10.0.0.0/16", "192.168.0.0/16"]
}

variable "nr-key" {
  default = "eu01xxfbfa5c82f2e8c583a24f75fc22FFFFNRAL"
}
variable "nr-acc-id" {
  default = "6562021"
}
variable "nr-region" {
  default = "eu"
}
