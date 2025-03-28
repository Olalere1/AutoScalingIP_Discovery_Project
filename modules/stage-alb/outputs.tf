output "stage_lb_dns_name" {
  description = "DNS of the stage load balancer"
  value       = aws_lb.stage-alb.dns_name
}

output "stage_lb_zone_id" {
  description = "Zone ID of the stage load balancer"
  value       = aws_lb.stage-alb.zone_id
}

output "stage-tg-arn" {
  description = "value"
  value       = aws_lb_target_group.stage-alb-target-group.arn
}