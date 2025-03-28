terraform {
  backend "s3" {
    bucket         = "auto-discovery-mono-app-s3"
    key            = "infra-remote/tfstate"
    dynamodb_table = "auto-discovery-mono-app-dynamodb"
    region         = "eu-west-1"
    profile        = "petproject"
  }
}
