variable "region" {
  default = "us-west-2"
}

variable "env" {
  default = ""
}

variable "vpc_id" {
  default = ""
}

variable "ecr_name" {
  default = "terraform-aws-ecs-fargate-codepipeline-demo"
}

variable "ecr_image_tag" {
  default = ""
}

variable "ecs_cluster_name" {
  default = "ecs-playground"
}

variable "ecs_service_name" {
  default = "demo"
}

variable "task_cpu" {
  default = 256
}

variable "task_memory" {
  default = 512
}

variable "task_service_port" {
  default = 8080
}

variable "alb_listen_port" {
  default = 443
}

variable "desired_task_count" {
  default = 1
}

variable "domain" {
  default = "david74.dev"
}