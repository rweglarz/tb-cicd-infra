terraform {
  backend "s3" {
    bucket = "tfstate-tom"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }
}
