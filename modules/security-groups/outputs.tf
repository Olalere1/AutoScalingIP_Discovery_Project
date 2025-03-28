##########################
# Output for ASG Security Group
output "asg-sg-id" {
  description = "Security Group ID for ASG"
  value       = aws_security_group.asg-sg.id
}

output "asg-sg-name" {
  description = "Security Group Name for ASG"
  value       = aws_security_group.asg-sg.name
}

# Output for Nexus Security Group
output "nexus-sg-id" {
  description = "Security Group ID for Nexus"
  value       = aws_security_group.nexus-sg.id
}

output "nexus-sg-name" {
  description = "Security Group Name for Nexus"
  value       = aws_security_group.nexus-sg.name
}

# Output for Ansible & Bastion Host Security Group
output "ansible-bastion-sg-id" {
  description = "Security Group ID for Ansible & Bastion Host"
  value       = aws_security_group.ansible-bastion-sg.id
}

output "ansible_bastion-sg-name" {
  description = "Security Group Name for Ansible & Bastion Host"
  value       = aws_security_group.ansible-bastion-sg.name
}

# Output for RDS Security Group
output "rds-sg-id" {
  description = "Security Group ID for RDS"
  value       = aws_security_group.rds-sg.id
}

output "rds-sg-name" {
  description = "Security Group Name for RDS"
  value       = aws_security_group.rds-sg.name
}

output "sonarqube-id" {
  description = "Security Group ID for ASG"
  value       = aws_security_group.sonarqube-sg.id
}