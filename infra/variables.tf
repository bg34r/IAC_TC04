# AWS Configuration
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "key_name" {
  description = "AWS key pair name"
  type        = string
}

variable "grupoDeSeguranca" {
  description = "Security group name"
  type        = string
  default     = "microservico-dev-sg"
}

# Project Configuration
variable "project_name" {
  description = "Project name"
  type        = string
  default     = "microservico"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "api_repo_url" {
  description = "API repository URL"
  type        = string
  default     = "https://github.com/bg34r/api_microservico.git"
}

# Application Environment Variables
variable "app_env" {
  description = "Application environment"
  type        = string
  default     = "development"
}

variable "server_address" {
  description = "Server address"
  type        = string
}

variable "port" {
  description = "Application port"
  type        = string
}

variable "context_timeout" {
  description = "Context timeout"
  type        = string
}

# Database Configuration
variable "db_host" {
  description = "Database host"
  type        = string
}

variable "db_port" {
  description = "Database port"
  type        = string
}

variable "db_user" {
  description = "Database user"
  type        = string
}

variable "db_pass" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
}

# Queue URLs
variable "produto_queue_url" {
  description = "Product queue URL"
  type        = string
}

variable "cliente_queue_url" {
  description = "Client queue URL"
  type        = string
}

variable "pedido_queue_url" {
  description = "Order queue URL"
  type        = string
}

# Token Configuration
variable "access_token_expiry_hour" {
  description = "Access token expiry in hours"
  type        = string
}

variable "refresh_token_expiry_hour" {
  description = "Refresh token expiry in hours"
  type        = string
}

variable "access_token_secret" {
  description = "Access token secret"
  type        = string
}

variable "refresh_token_secret" {
  description = "Refresh token secret"
  type        = string
  sensitive   = true
}