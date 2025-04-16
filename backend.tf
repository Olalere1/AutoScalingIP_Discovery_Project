terraform {
  backend "s3" {
    bucket         = "auto-discovery-mono-app-s3"
    key            = "infra-remote/tfstate"
    dynamodb_table = "auto-discovery-mono-app-dynamodb"
    region         = "eu-west-1"
    profile        = "cbauser_admin" #You might need to comment this out in infra-pipeline build!
  }
}
