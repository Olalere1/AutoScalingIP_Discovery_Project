
output "jenkins-node-public-ip" {
  value = module.jenkins-servers.jenkins-node-public-ip
}

output "jenkins-docker-public-ip" {
  value = module.jenkins-servers.jenkins-docker-public-ip
}

output "nexus-public-ip" {
  value = module.nexus-server.nexus-server-public-ip
}
output "sonarqube-public-ip" {
  value = module.sonarqube-server.sonarqube-public-ip
}

output "ansible-private-ip" {
  value = module.ansible-server.ansible-server-private-ip
}

output "bastion-host-ip" {
  value = module.bastion-host.bastion-host-ip
}

output "rds-endpoint" {
  value = module.rds-database.rds_endpoint
}
