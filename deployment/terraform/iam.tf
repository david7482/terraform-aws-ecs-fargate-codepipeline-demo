################################
# IAM
################################

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
resource "aws_iam_role" "service_task_execution_role" {
  name = "david74-${var.ecs_service_name}-${var.region}-${var.env}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF

  tags = {
    Name        = "${var.ecs_service_name}-${var.env}-role"
    Environment = var.env
    Purpose     = var.ecs_service_name
  }
}

resource "aws_iam_role_policy_attachment" "service_task_execution_policy" {
  role       = aws_iam_role.service_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

###############################
# Attach service inline policy
###############################
data "aws_caller_identity" "current" {
}

data "aws_iam_policy_document" "inline_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "inline_policy" {
  name   = "inline-policy"
  role   = aws_iam_role.service_task_execution_role.name
  policy = data.aws_iam_policy_document.inline_policy.json
}
