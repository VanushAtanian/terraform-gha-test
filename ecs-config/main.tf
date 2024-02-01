provider "aws" {
  region     = var.REGION
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

#------------------------------------------------------------

terraform {
  backend "s3" {
    bucket = "van-presentation-terraform-state"
    key    = "dev/presentation/terraform.tfstate"
    region = "eu-central-1"
    # access_key = "AKIA2FRWNY5MJLC3L7GS"
    # secret_key = "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"
  }
}

data "terraform_remote_state" "ecr" {
  backend = "s3"
  config = {
    bucket = "van-presentation-terraform-state"
    key    = "dev/presentation/terraform.tfstate"
    region = "eu-central-1" // Region where bycket created
  }
}

resource "aws_ecs_cluster" "main_cluster" {
  name = "main-cluster"
}


resource "aws_ecs_task_definition" "main_task_definition" {
  family = "main-task-family"
  container_definitions = jsonencode([
    {
      "name"      = "main-container",
      "image"     = "${data.terraform_remote_state.ecr.outputs.ecr_repository_url}:java_demo_image",
      "cpu"       = 256,
      "memory"    = 512,
      "essential" = true,
      "portMappings" = [
        {
          "containerPort" = 80,
          "hostPort"      = 80,
          "protocol"      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "main_service" {
  name            = "main-service"
  cluster         = aws_ecs_cluster.main_cluster.id
  task_definition = aws_ecs_task_definition.main_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE" 
  network_configuration {
    subnets          = data.terraform_remote_state.ecr.outputs.subnet_id
    security_groups  = data.terraform_remote_state.ecr.outputs.security_group_id
    assign_public_ip = true
  }
}