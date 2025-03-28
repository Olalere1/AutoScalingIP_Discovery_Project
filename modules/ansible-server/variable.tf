variable "redhat-ami-id" {}
variable "instance-type" {}
variable "ssh-key-name" {}      
variable "public-subnet-id" {}
variable "ansible-sg" {}
variable "stage-playbook" {}
variable "prod-playbook" {}
variable "stage-discovery-script" {}
variable "prod-discovery-script" {}
variable "private-key" {}
variable "nexus-ip" {}
variable "nr-key" {}
variable "nr-acc-id" {}
variable "nr-region" {}

# Could not find some of this variables in the tfvars file/or variables.tf of main!