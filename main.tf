provider "aws" {
  region     = eu-central-1
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
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
