resource "aws_autoscaling_policy" "demo-cpu-policy" {
  name                   = "demo-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.demo.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "demo-cpu-alarm" {
  alarm_name          = "demo-cpu-alarm"
  alarm_description   = "demo-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "60"
  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.demo.name}"
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.demo-cpu-policy.arn]
}

resource "aws_autoscaling_policy" "demo-cpu-policy-scaledown" {
  name                   = "demo-cpu-policy-scaledown"
  autoscaling_group_name = aws_autoscaling_group.demo.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"

}

resource "aws_cloudwatch_metric_alarm" "demo-cpu-alarm-scaledown" {
  alarm_name          = "demo-cpu-alarm-scaledown"
  alarm_description   = "demo-cpu-alarm-scaledown"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "50"
  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.demo.name}"
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.demo-cpu-policy-scaledown.arn]
}
