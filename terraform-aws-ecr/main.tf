resource "aws_ecr_repository" "aws_ecr_repository" {
  name                 = var.name
  image_tag_mutability = var.ecr_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.ecr_scan
  }
}