terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket = "terraform-remote-backend-s3-bkt"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }


}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

