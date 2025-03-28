resource "aws_launch_template" "stage-lt" {
  name                   = "stage-lt"
  image_id               = var.redhat
  instance_type          = "t2.medium"
  vpc_security_group_ids = var.stage-sg
  key_name               = var.pub-key
  user_data = base64encode(templatefile("./modules/stage-asg/docker-script.sh", {
    nexus-ip             = var.nexus-ip-stage,
    newrelic-license-key = var.nr-key,
    newrelic-account-id  = var.nr-acc-id,
    newrelic-region      = var.nr-region
  }))

  tags = {
    Name = "lt-stage"
  }

}

#Create AutoScaling Group
resource "aws_autoscaling_group" "stage-asg" {
  name                      = var.asg-stage-name
  desired_capacity          = 1
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true
  vpc_zone_identifier       = var.vpc-zone-identifier
  target_group_arns         = [var.tg-stage]
  launch_template {
    id = aws_launch_template.stage-lt.id
  }
  tag {
    key                 = "Name"
    value               = var.asg-stage-name
    propagate_at_launch = true
  }
}

#Create ASG Policy
resource "aws_autoscaling_policy" "stage-asg-policy" {
  name                   = "stage-asg-policy"
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.stage-asg.id
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0
  }
}