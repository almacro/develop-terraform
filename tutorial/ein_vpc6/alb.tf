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
resource "aws_alb_target_group" "docker-demo-tg" {
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
    target_group_arn = aws_alb_target_group.docker-demo-tg.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "docker_demo" {
  count            = length(var.azs)
  target_group_arn = aws_alb_target_group.docker-demo-tg.arn
  target_id        = element(split(",", join(",", aws_instance.docker_demo.*.id)), count.index)
  port             = 80
}
