provider "aws" {
  region  = var.region
  profile = var.profile                   #You might need to comment this out in infra-pipeline build!
}

provider "vault" {
  token   = "s.Tqey2CbX1Qci6gKwwmmSKLJt"       #Update after creating Vault server - Olalere
  address = "https://vault.aquinas.site/"
}
