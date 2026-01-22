terraform {
  required_version = ">= 1.10"  # Required for S3 native locking

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "aws_region" {
 description = "AWS Region that Infra will be built in"
 type = string
}


provider "aws" {
  region = var.aws_region
}

# Generate unique suffix to avoid bucket name conflicts
resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  bucket_name = "gatus-project-${random_id.suffix.hex}"
}

# S3 bucket for state storage
resource "aws_s3_bucket" "state" {
  bucket = local.bucket_name

  tags = {
    Name    = "Terraform State"
    Project = "gatus-project"
  }
}

# Enable versioning for state recovery
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ECR Boostrap
resource "aws_ecr_repository" "gatus" {
  name                 = "gatus-repo"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "AES256"
  }
lifecycle {
    prevent_destroy = true
  }


  tags = { Name = "gatus-repo" }

}


# Output values needed for backend and ECR configuration
output "repo_url" {
  value = aws_ecr_repository.gatus.repository_url
}

output "state_bucket" {
  value       = aws_s3_bucket.state.id
  description = "S3 bucket name for terraform state"
}

output "region" {
  value       = var.aws_region
  description = "AWS region"
}




