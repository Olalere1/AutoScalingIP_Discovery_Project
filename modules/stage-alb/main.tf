### Creating Load Balancer for ASG Stage
resource "aws_lb" "stage-alb" {
  name               = var.alb-name-stage
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.asg-sg            # Ensure a security group allows HTTP/HTTPS
  subnets            = var.public-subnets    # Attach to public subnets

  enable_deletion_protection = false
  drop_invalid_header_fields = true

  tags = {
    Name = "Stage-ALB"
  }
}

## HTTP Listener
resource "aws_lb_listener" "stage-http-listener" {
  load_balancer_arn = aws_lb.stage-alb.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

## HTTPS Listener
resource "aws_lb_listener" "stage-https-listener" {
  load_balancer_arn = aws_lb.stage-alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.cert-arn             # Replace with actual certificate ARN

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.stage-alb-target-group.arn
  }
}

### Creating a target group for stage ASG
resource "aws_lb_target_group" "stage-alb-target-group" {
  name     = "stage-asg-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc-id                       # Replace with your actual VPC ID


  health_check {
    interval            = 30
    timeout             = 5
    healthy_threshold   = 4
    unhealthy_threshold = 4
    matcher             = "200"
  }

  tags = {
    Name = "stage-ALB-TargetGroup"
  }
}
