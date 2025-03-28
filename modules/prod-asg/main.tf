# Create Launch Template
resource "aws_launch_template" "production-lt" {
  name                   = "production-lt"
  image_id               = var.redhat
  instance_type          = "t2.medium"
  vpc_security_group_ids = var.prod-sg
  key_name               = var.pub-key
  user_data = base64encode(templatefile("./modules/prod-asg/docker-script.sh", {
    nexus-ip             = var.nexus-ip-prd,
    newrelic-license-key = var.nr-key,
    newrelic-account-id  = var.nr-acc-id,
    newrelic-region      = var.nr-region
  }))

  tags = {
    Name = "lt-prd"
  }

}

#Create AutoScaling Group
resource "aws_autoscaling_group" "production-asg" {
  name                      = var.asg-prd-name
  desired_capacity          = 1
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true
  vpc_zone_identifier       = var.vpc-zone-identifier
  target_group_arns         = [var.tg-prod]
  launch_template {
    id = aws_launch_template.production-lt.id
  }
  tag {
    key                 = "Name"
    value               = var.asg-prd-name
    propagate_at_launch = true
  }
}

#Create ASG Policy
resource "aws_autoscaling_policy" "asg-policy" {
  name                   = "prd-asg-policy"
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.production-asg.id
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0
  }
}