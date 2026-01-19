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


  tags = { Name = "${var.project_name}-repo" }
}

