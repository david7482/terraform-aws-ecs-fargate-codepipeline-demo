resource "aws_ecr_repository" "demo" {
  name                 = "terraform-aws-ecs-fargate-codepipeline-demo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}