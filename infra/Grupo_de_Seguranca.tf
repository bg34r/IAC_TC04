resource "random_id" "sg_suffix" {
  byte_length = 4
}

resource "aws_security_group" "acesso_geral" {
  name        = "${var.grupoDeSeguranca}-${random_id.sg_suffix.hex}"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 significa todos os protocolos
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
  
  tags = {
    Name = "Microservico-Security-Group-${var.environment}-${random_id.sg_suffix.hex}"
    Environment = var.environment
  }
}