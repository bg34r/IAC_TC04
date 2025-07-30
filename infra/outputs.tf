output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "IP público da instância EC2"
  value       = aws_instance.app_server.public_ip
}

output "instance_public_dns" {
  description = "DNS público da instância EC2"
  value       = aws_instance.app_server.public_dns
}

output "security_group_id" {
  description = "ID do grupo de segurança"
  value       = aws_security_group.acesso_geral.id
}

output "ssh_command" {
  description = "Comando para conectar via SSH"
  value       = "ssh -i sua-chave.pem ubuntu@${aws_instance.app_server.public_ip}"
}

output "application_url" {
  description = "URL da aplicação"
  value       = "http://${aws_instance.app_server.public_ip}:8080"
}