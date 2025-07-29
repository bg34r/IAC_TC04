variable "region" {
  description = "The AWS region to deploy the EC2 instance"
  default     = "us-west-2"
}

variable "instance_type" {
  description = "The type of EC2 instance to use"
  type        = string
  default     = "t3.micro"
}

variable "api_repo_url" {
  description = "URL do repositório Git da API"
  type        = string
  default     = "https://github.com/bg34r/api_microservico.git"
}

variable "key_name" {
  description = "The name of the key pair to use for SSH access"
  type        = string
}

variable "project_name" {
  description = "Name of the project for tagging"
  type        = string
  default     = "api_produtos_pedidos"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "grupoDeSeguranca" {
  description = "Name of the security group"
  type        = string
  default     = "Grupo de Segurança Dev"
}