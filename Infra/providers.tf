terraform {
  backend "s3" {
    bucket = "terraform-state-bryn-test"
    key    = "scheduler-madness"
    region = "us-east-1"

  }


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}
