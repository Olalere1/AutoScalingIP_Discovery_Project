output "nexus-server-public-ip" {
  value = aws_instance.nexus-server.public_ip
}

output "nexus-lb-dns-name" {
  description = "DNS of the nexus host"
  value       = aws_elb.nexus-server-elb.dns_name
}

output "nexus-lb-zone-id" {
  description = "Zone ID of the nexus load balancer"
  value       = aws_elb.nexus-server-elb.zone_id
}