output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.rds-instance.endpoint
}

output "rds_instance_id" {
  description = "RDS Instance ID" # Useful for monitoring / if alarms or additional configurations needs to be created later
  value       = aws_db_instance.rds-instance.id
}