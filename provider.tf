provider "aws" {
  region  = var.region
  profile = var.profile                   #You might need to comment this out in infra-pipeline build!
}

provider "vault" {
  token   = "s.8AVATiQVYyjVJm7tMwkZgVTA"       #Update after creating Vault server - Olalere
  address = "https://vault.aquinas.site/"
}
