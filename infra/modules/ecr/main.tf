resource "aws_ecr_repository" "gatus_ecr" {
  name                 = "gatus_repo"
  image_tag_mutability = "IMMUTABLE"  # or "IMMUTABLE" based on your requirement
  image_scanning_configuration {
    scan_on_push = true
  }
}