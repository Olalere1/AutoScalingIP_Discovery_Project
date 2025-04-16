provider "aws" {
  region = var.region
  profile = var.profile                   #You might need to comment this out in infra-pipeline build!
}

provider "vault" {
  token   = "s.1mOWGjw5I5Mo6BTJXcyHIVMN" #Update after creating Vault server - Olalere
  address = "https://vault.aquinas.site/"
}
