provider "aws" {
  region  = var.region
  profile = var.profile
}

provider "vault" {
  token   = "s.Tqey2CbX1Qci6gKwwmmSKLJt"       #Update after creating Vault server - Olalere
  address = "https://vault.hullerdata.com/"
}
