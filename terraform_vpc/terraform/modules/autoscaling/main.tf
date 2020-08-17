# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

data "template_file" "userdata" {
  template = "${file("${path.module}/template/userdata.sh")}"
}

resource "aws_launch_configuration" "launchconfig" {
  name_prefix     = "${terraform.workspace}-${var.name}-launch-configuration"
  image_id        = var.amis
  instance_type   = var.aws-instance-type
  key_name        = var.keypair-name
  security_groups = [var.instance-security-group-id]
  lifecycle {
create_before_destroy = true
}
  user_data = data.template_file.userdata.template
  
}

resource "aws_autoscaling_group" "autoscaling" {
  name                      = "${terraform.workspace}-${var.name}-autoscaling-group"
  vpc_zone_identifier       = var.private-subnets
  launch_configuration      = aws_launch_configuration.launchconfig.name
  protect_from_scale_in = false
  min_size                  = 0
  desired_capacity          = 0
  max_size                  = 5
  health_check_grace_period = 120
  health_check_type         = "EC2"
  default_cooldown          = 120
  force_delete              = true

  tag {
    key                 = "Name"
    value               = "${terraform.workspace}-${var.name}-ec2 instance"
    propagate_at_launch = true
  }
}
resource "aws_autoscaling_policy" "autoscaling-policy-scale-up" {
  name                   = "${terraform.workspace}-${var.name}-autoscaling-policy-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = aws_autoscaling_group.autoscaling.name
}
resource "aws_autoscaling_policy" "autoscaling-policy-scale-down" {
    name = "${terraform.workspace}-${var.name}-autoscaling-policy-scale-down"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 120
    autoscaling_group_name = aws_autoscaling_group.autoscaling.name
}
resource "aws_cloudwatch_metric_alarm" "scale-up" {
  alarm_name          = "${terraform.workspace}-${var.name}-scale-up-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.autoscaling-policy-scale-up.arn}"]
}
resource "aws_cloudwatch_metric_alarm" "scale-down" {
  alarm_name          = "${terraform.workspace}-${var.name}-scale-down-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.autoscaling-policy-scale-down.arn}"]
}

