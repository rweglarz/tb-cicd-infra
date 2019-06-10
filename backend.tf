terraform {
  backend "s3" {
    bucket = "terraform-tfstate-tom"
    key    = "terraform.tfstate"
    region = "ap-southeast-1"
  }
}
