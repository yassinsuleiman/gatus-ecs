terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.2.0"
    }
  }
}

# Configure the AWS region
provider "aws" {
  region = var.aws_region
}