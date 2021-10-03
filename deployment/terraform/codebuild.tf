################################
# Locals
################################
locals {
  codebuild_name = format("%s-%s-codebuild", var.ecs_service_name, var.env)
}

################################
# Cloudwatch Logs
################################

# Set up cloudwatch group and log stream and retain logs for 14 days
resource "aws_cloudwatch_log_group" "codebuild_log_group" {
  name              = "/aws/codebuild/${var.ecs_service_name}-${var.env}"
  retention_in_days = 14

  tags = {
    Name        = "${var.ecs_service_name}-${var.env}-log-group"
    Environment = var.env
    Purpose     = var.ecs_service_name
  }
}

################################
# IAM
################################
resource "aws_iam_role" "codebuild_role" {
  name = "david74-${var.ecs_service_name}-${var.region}-codebuild-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF

  tags = {
    Name        = "${var.ecs_service_name}-codebuild-role"
    Environment = "internal"
    Purpose     = var.ecs_service_name
  }
}

data "aws_iam_policy_document" "codebuild_inline_policy" {
  statement {
    sid    = "AllowS3"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowECR"
    effect = "Allow"

    actions = [
      "ecr:*"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AWSKMSUse"
    effect = "Allow"

    actions = [
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:Decrypt"
    ]

    resources = ["*"]
  }

  statement {
    sid       = "AllowECSDescribeTaskDefinition"
    effect    = "Allow"
    actions   = ["ecs:DescribeTaskDefinition"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowLogging"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codebuild_inline_policy" {
  name   = "inline-policy"
  role   = aws_iam_role.codebuild_role.name
  policy = data.aws_iam_policy_document.codebuild_inline_policy.json
}

################################
# CodeBuild
################################
resource "aws_codebuild_project" "main" {
  name         = local.codebuild_name
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/docker:18.09.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.codebuild_log_group.name
      stream_name = "build-id"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/${var.github_owner}/${var.github_repo}.git"
    git_clone_depth = 1
  }

  source_version = "master"
}