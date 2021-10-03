################################
# Locals
################################
locals {
  codepipeline_name = format("%s-%s-codepipeline", var.ecs_service_name, var.env)
}

################################
# IAM
################################
resource "aws_iam_role" "codepipeline_role" {
  name = "david74-${var.ecs_service_name}-${var.region}-codepipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF

  tags = {
    Name        = "${var.ecs_service_name}-codepipeline-role"
    Environment = "internal"
    Purpose     = var.ecs_service_name
  }
}

data "aws_iam_policy_document" "codepipeline_inline_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:DescribeImages"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codepipeline_inline_policy" {
  name   = "inline-policy"
  role   = aws_iam_role.codepipeline_role.name
  policy = data.aws_iam_policy_document.codepipeline_inline_policy.json
}

################################
# CodePipeline
################################
resource "aws_s3_bucket" "codepipeline" {
  bucket = format("david74-%s-%s-codepipeline", var.ecs_service_name, var.env)
  acl    = "private"
}

resource "aws_codepipeline" "main" {
  name     = local.codepipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        OAuthToken = var.github_token
        Owner      = var.github_owner
        Repo       = var.github_repo
        Branch     = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]

      configuration = {
        ProjectName = aws_codebuild_project.main.name
      }
    }
  }
}