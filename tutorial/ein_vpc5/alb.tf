# Security Group for Load Balancer
resource "aws_security_group" "docker_demo_alb_sg" {
  name        = "Docker-Nginx-Demo-ALB-SG"
  description = "Allow incoming HTTP traffic only"
  vpc_id      = aws_vpc.demo.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-alb"
  }
}

# Load Balancer, ALB
# instances in private subnets
resource "aws_alb" "docker_demo_alb" {
  name            = "docker-demo-alb"
  security_groups = [aws_security_group.docker_demo_alb_sg.id]
  subnets         = aws_subnet.public.*.id
  tags = {
    Name = "alb-demo"
  }
}

# ALB Target Group
resource "aws_alb_target_group" "docker_demo_alb_tg" {
  name     = "docker-demo-alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.demo.id
  health_check {
    path = "/"
    port = 80
  }
}

# ALB Listener
resource "aws_alb_listener" "http_listener" {
  load_balancer_arn = aws_alb.docker_demo_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.docker_demo_alb_tg.arn
    type             = "forward"
  }
}

resource "aws_launch_configuration" "demo" {
  image_id        = lookup(var.ec2_amis, var.aws_region)
  instance_type   = "t3a.micro"
  key_name = "terraform-demo"
  security_groups = [aws_security_group.docker_demo_ec2.id]
  user_data       = file("user_data.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "docker_demo_asg" {
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

resource "aws_autoscaling_attachment" "demo_asg_attachment" {
  alb_target_group_arn   = aws_alb_target_group.docker_demo_alb_tg.arn
  autoscaling_group_name = aws_autoscaling_group.docker_demo_asg.id
}

output "url" {
  value = "http://${aws_alb.docker_demo_alb.dns_name}/"
}