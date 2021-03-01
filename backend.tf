terraform {
  backend "s3" {
    bucket = "tfstate-tom2"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }
}
