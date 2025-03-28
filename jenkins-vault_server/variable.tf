##########################
# Jenkins-Vault-Server
variable "region" {
  default = "eu-west-1"
}

variable "profile" {                   # AWS profile likely to be changed - Olalere
  default = "petproject"
}
variable "ami-ubuntu" {
  default = "ami-091f18e98bc129c4e" #Ubuntu ami for Vault server
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
  default = "ami-0f9535ac605dc21d5" #Redhat ami for jenkins server
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

variable "nr-key" {}
variable "nr-acc-id" {} 
variable "nr-region" {}
