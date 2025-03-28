# 🔹 RDS Subnet Group
resource "aws_db_subnet_group" "rds-subnet-group" {
  name        = "multi-az-rds-subnet-group"
  subnet_ids  = var.db-subnet-id          # Use private subnets for security
  description = "Subnet group for Multi-AZ RDS deployment"

  tags = {
    Name = "Multi-AZ-RDS-Subnet-Group"
  }
}

# 🔹 Multi-AZ RDS Instance
resource "aws_db_instance" "rds-instance" {
  #checkov:skip=CKV_AWS_118: RDS detailed monitoring will be enfored on the stage/production environment
  #checkov:skip=CKV_AWS_226: RDS automatic upgrade will be enfored on the stage/production environment
  #checkov:skip=CKV_AWS_129: RDS logging will be enfored on the stage/production environment
  #checkov:skip=CKV_AWS_157: RDS Multi-AZ will be enfored on the stage/production environment
  #checkov:skip=CKV_AWS_293: RDS deletion protectoin will be enfored on the stage/production environment
  #checkov:skip=CKV_AWS_354: RDS encryption will be enfored on the stage/production environment
  #checkov:skip=CKV_AWS_161: RDS IAM authentication will be enfored on the stage/production environment
  identifier             = "petclinic"
  allocated_storage      = 20
  engine                 = "mysql"       # Change to "postgres", "mariadb", etc. if needed
  engine_version         = "5.7"         # Change version based on requirements
  instance_class         = "db.t3.micro" # Modify as needed
  db_name                = var.db-name
  username               = var.db-username
  password               = var.db-password # Use AWS Secrets Manager instead of hardcoding!
  parameter_group_name   = "default.mysql5.7"
  multi_az               = true         # I changed to true for Multi-AZ
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.rds-subnet-group.name
  vpc_security_group_ids = var.vpc-sg-id # References our SG module
  storage_encrypted      = true
  skip_final_snapshot    = true

  tags = {
    Name        = "rds-instance"
    Environment = "dev"
  }
}

