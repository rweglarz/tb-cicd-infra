terraform {
  backend "s3" {
    bucket = "rwe-tb-cicd-infra-tfstate"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }
}
