# Output values
output "vault-public-ip" {
  value = aws_instance.vault-server.public_ip
}

output "jenkins-public-ip" {
  description = "Public IP of the jenkins host"
  value       = aws_instance.jenkins-server.public_ip
}

output "jenkins-sg-id" {
  value = aws_security_group.jenkins-sg.id
}


##################################
output "vpc-id" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC"
}

output "public-subnet-id-1" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets[0]
}

output "public-subnet-id-2" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets[1]
}

output "public-subnet-id-3" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets[2]
}

output "private-subnet-id-1" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets[0]
}

output "private-subnet-id-2" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets[1]
}

output "private-subnet-id-3" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets[2]
}

output "cert-arn" {
  description = "value"
  value       = aws_acm_certificate.cert.arn
}