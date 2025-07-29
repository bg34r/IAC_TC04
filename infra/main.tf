terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Data source para pegar a VPC padrão
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami                     = "ami-05f991c49d264708f" # Ubuntu Linux 2024 us-west-2
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.acesso_geral.id]
  subnet_id              = data.aws_subnets.default.ids[0]
  
  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    api_repo_url = var.api_repo_url
  }))

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-server"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Elastic IP (opcional, mas recomendado)
resource "aws_eip" "app_eip" {
  instance = aws_instance.app_server.id
  domain   = "vpc"

  tags = {
    Name        = "${var.project_name}-${var.environment}-eip"
    Environment = var.environment
    Project     = var.project_name
  }
}