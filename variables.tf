########################
variable "region" {}
variable "profile" {}
variable "project-name" {}
variable "instance-type" {}

## security-groups
variable "allowed-ssh-ips" {} # Restrict this IPs in production later if needed
variable "asg-port" {}
variable "nexus-port-1" {}
variable "nexus-port-2" {}
variable "sonar-port" {}
variable "rds-port" {}

## AMIs
variable "redhat-ami-id" {}
variable "ubuntu-ami-id" {}

## New Relic
variable "nr-region" {}
variable "nr-key" {}
variable "nr-acc-id" {}

#############
variable "db-name" {}

## sonarqube-server
variable "sonar-postgress-pwd" {}
variable "sonar-psqldb-pwd" {}

################
## records
variable "domain-name" {}
variable "prod-domain-name" {}
variable "stage-domain-name" {}
variable "sonarqube-domain-name" {}
variable "nexus-domain-name" {}
