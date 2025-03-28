output "prod_lb_dns_name" {
  description = "DNS of the prod host"
  value       = aws_lb.prod-alb.dns_name
}

output "prod_lb_zone_id" {
  description = "Zone ID of prod load balancer"
  value       = aws_lb.prod-alb.zone_id
}

output "prod-tg-arn" {
  description = "value"
  value       = aws_lb_target_group.prod-alb-target-group.arn
}