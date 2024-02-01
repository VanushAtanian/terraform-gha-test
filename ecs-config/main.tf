provider "aws" {
  region     = var.REGION
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

#------------------------------------------------------------

terraform {
  backend "s3" {
    bucket = "van-presentation-terraform-state"
    key    = "cluster/presentation/terraform.tfstate"
    region = "eu-central-1"
    # access_key = "AKIA2FRWNY5MJLC3L7GS"
    # secret_key = "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"
  }
}

data "terraform_remote_state" "ecr" {
  backend = "s3"
  config = {
    bucket = "van-presentation-terraform-state"
    key    = "preq/presentation/terraform.tfstate"
    region = "eu-central-1" // Region where bycket created
  }
}

resource "aws_ecs_cluster" "main_cluster" {
  name = "main-cluster"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_ecs_task_definition" "main_task_definition" {
  family                   = "main-task-family"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      "name"      = "main-container",
      "image"     = "${data.terraform_remote_state.ecr.outputs.ecr_repository_url}:java_demo_image",
      "cpu"       = 256,
      "memory"    = 512,
      "essential" = true,
      "portMappings" = [
        {
          "containerPort" = 8080,
          "hostPort"      = 8080,
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
    subnets          = [data.terraform_remote_state.ecr.outputs.subnet_id]
    security_groups  = [data.terraform_remote_state.ecr.outputs.security_group_id]
    assign_public_ip = true
  }
}
