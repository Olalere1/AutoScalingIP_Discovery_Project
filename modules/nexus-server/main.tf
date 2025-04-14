resource "aws_instance" "nexus-server" {
  #checkov:skip=CKV_AWS_135: Optimazation will be enfored on the stage/production environment
  #checkov:skip=CKV_AWS_126: detailed monitoring will be enfored on the stage/production environment
  #checkov:skip=CKV_AWS_88: using public ip for testing purposes, it will be enfored on the stage/production environment
  ami                         = var.redhat-ami-id
  instance_type               = var.instance-type
  key_name                    = var.key-name
  subnet_id                   = var.subnet-id
  vpc_security_group_ids      = var.nexus-sg-id
  associate_public_ip_address = true
  user_data                   = local.nexuscript
  metadata_options {
    http_tokens = "required"
  }
  root_block_device {
    volume_size = 50
    volume_type = "gp3"
    encrypted   = "true"
  }
  tags = {
    Name = "Nexus-Server"
  }
}

# Creating elb for nexus server
resource "aws_elb" "nexus-server-elb" {
  name            = "nexus-server-elb"
  security_groups = var.nexus-sg-id
  subnets         = var.public-subnets
  listener {
    instance_port      = 8085
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = var.ssl-cert-id
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:8085"
    interval            = 30
  }

  instances                   = [aws_instance.nexus-server.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "nexus-server-elb"
  }

}