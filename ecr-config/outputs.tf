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

output "subnet_id" {
  value = aws_subnet.main_subnet.id
}

output "security_group_id" {
  value = aws_security_group.ecs_security_group.id
}

output "vpc_id" {
  value = aws_vpc.main
}

output "ecr_repository_url" {
  value = aws_ecr_repository.ecr_repository.repository_url
}
