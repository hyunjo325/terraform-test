resource "aws_ecr_repository" "this" {
  name = var.name
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = var.name
  }
}

