terraform {
  backend "s3" {
    bucket         = "staging-vijay-app-bucket"
    key            = "stagingtest/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "staging-vijay-app-table"
  }
}
