output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_eip.app_eip.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.app_server.public_dns
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.acesso_geral.id
}

output "ssh_connection_command" {
  description = "Command to SSH into the instance"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_eip.app_eip.public_ip}"
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${aws_eip.app_eip.public_ip}:8080"
}