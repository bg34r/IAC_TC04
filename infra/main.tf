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
    APP_ENV = var.app_env
    SERVER_ADDRESS = var.server_address
    PORT = var.port
    CONTEXT_TIMEOUT = var.context_timeout
    DB_HOST = var.db_host
    DB_PORT = var.db_port
    DB_USER = var.db_user
    DB_PASS = var.db_pass
    DB_NAME = var.db_name
    PRODUTO_QUEUE_URL = var.produto_queue_url
    CLIENTE_QUEUE_URL = var.cliente_queue_url
    PEDIDO_QUEUE_URL = var.pedido_queue_url
    ACCESS_TOKEN_EXPIRY_HOUR = var.access_token_expiry_hour
    REFRESH_TOKEN_EXPIRY_HOUR = var.refresh_token_expiry_hour
    ACCESS_TOKEN_SECRET = var.access_token_secret
    REFRESH_TOKEN_SECRET = var.refresh_token_secret
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