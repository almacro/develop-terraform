resource "aws_launch_configuration" "demo" {
  image_id        = lookup(var.ec2_amis, var.aws_region)
  instance_type   = "t3a.micro"
  key_name        = "terraform-demo"
  security_groups = [aws_security_group.docker_demo_ec2.id]
  user_data       = file("user_data.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "demo" {
  name = "docker-demo-autoscaling-group"

  launch_configuration = aws_launch_configuration.demo.id
  vpc_zone_identifier  = aws_subnet.private.*.id

  desired_capacity = 3
  max_size         = 6
  min_size         = 1

  health_check_type = "ELB"
  tag {
    key                 = "Name"
    value               = "docker-demo-asg"
    propagate_at_launch = true
  }
}

output "url" {
  value = "http://${aws_alb.docker_demo_alb.dns_name}/"
}