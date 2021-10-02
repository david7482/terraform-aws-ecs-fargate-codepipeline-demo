################################
# Cloudwatch Logs
################################

# Set up cloudwatch group and log stream and retain logs for 14 days
resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/ecs/${var.ecs_service_name}-${var.env}"
  retention_in_days = 14

  tags = {
    Name        = "${var.ecs_service_name}-${var.env}-log-group"
    Environment = var.env
    Purpose     = var.ecs_service_name
  }
}
