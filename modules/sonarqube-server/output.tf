output "sonarqube-public-ip" {
  description = "Public IP of the sonarqube host"
  value       = aws_instance.sonarqube_instance.public_ip
}

output "sonarqube-instance-id" {
  description = "ID of the sonarqube host instance"
  value       = aws_instance.sonarqube_instance.id
}

output "sonarqube-lb-dns-name" {
  description = "DNS of the sonarqube host"
  value       = aws_elb.elb-sonar.dns_name
}

output "sonarqube-lb-zone-id" {
  description = "Zone ID of the sonarqube load balancer"
  value       = aws_elb.elb-sonar.zone_id
}