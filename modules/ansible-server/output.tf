output "ansible-server-private-ip" {
  description = "Private IP of the Ansible server"
  value       = aws_instance.ansible-server.private_ip
}
