
# Output values needed for backend and ecr configuration
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