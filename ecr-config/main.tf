provider "aws" {
  region     = var.REGION
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

#------------------------------------------------------------

terraform {
  backend "s3" {
    bucket     = "van-presentation-terraform-state"
    key        = "dev/presentation/terraform.tfstate"
    region     = "eu-central-1"
    # access_key = "AKIA2FRWNY5MJLC3L7GS"
    # secret_key = "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"
  }
}

data "aws_ami" "latest_ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

data "aws_ami" "latest_amazon" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}

#------------------------------------------------------------
resource "aws_ecr_repository" "ecr_repository" {
  name                 = "gha"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}


output "data_ubuntu_ami_id" {
  value = data.aws_ami.latest_ubuntu.id
}

output "data_ubuntu_ami_name" {
  value = data.aws_ami.latest_ubuntu.name
}

output "data_amazon_linux_ami_id" {
  value = data.aws_ami.latest_amazon.id
}

output "data_amazon_linux_ami_name" {
  value = data.aws_ami.latest_amazon.name
}