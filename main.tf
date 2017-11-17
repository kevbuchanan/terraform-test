terraform {
  backend "s3" {
    bucket = "terraform-test-tf"
    key    = ".tfstate"
    region = "us-east-1"
    profile = "terraform-test"
  }
}

provider "aws" {
  region = "us-east-1"
  profile = "terraform-test"
}
