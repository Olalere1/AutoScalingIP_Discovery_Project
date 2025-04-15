provider "aws" {
  region  = var.region
  #profile = var.profile                   #You might need to comment this out in infra-pipeline build!
}

provider "vault" {
  token   = "s.c3Wn5nMRXu8DwhQ0sV3oXmlN"       #Update after creating Vault server - Olalere
  address = "https://vault.aquinas.site/"
}
