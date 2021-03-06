# Security Group for Load Balancer
resource "aws_security_group" "docker_demo_elb" {
  name        = "Docker-Demo-ELB-SG"
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
}

# Load Balancer, ELB-Classic
# instances in private subnets
resource "aws_elb" "docker_demo" {
  name                      = "docker-demo-elb"
  cross_zone_load_balancing = true
  subnets                   = aws_subnet.private.*.id

  # short interval and threshold values to reduce time for Instances to become "healthy"
  health_check {
    unhealthy_threshold = 2
    healthy_threshold   = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 20
  }

  # references ec2 instances created in ec2.tf
  instances = aws_instance.docker_demo.*.id

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  security_groups = [
    aws_security_group.docker_demo_elb.id,
  ]
}

output "url" {
  value = "http://${aws_elb.docker_demo.dns_name}/"
}