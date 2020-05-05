terraform {
  required_version = ">= 0.12"
}

data "aws_vpc" "selected" {
  id = var.selected_vpc
}

data "aws_subnet_ids" "selected" {
  vpc_id = data.aws_vpc.selected.id
  filter {
    name   = "tag:Name"
    values = ["vpn-pub"]
  }
}
resource "aws_launch_configuration" "asg-launch-config-sample" {
  image_id        = "ami-0d1cd67c26f5fca19"
  instance_type   = "t3a.nano"
  security_groups = [aws_security_group.busybox.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, Terraform & AWS ASG" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "busybox" {
  name   = "${var.cluster_name}-busybox-sg"
  vpc_id = data.aws_vpc.selected.id

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "elb-sg" {
  name   = "${var.cluster_name}-elb-sg"
  vpc_id = data.aws_vpc.selected.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = var.elb_port
    to_port     = var.elb_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "asg-sample" {
  launch_configuration = aws_launch_configuration.asg-launch-config-sample.id
  vpc_zone_identifier  = data.aws_subnet_ids.selected.ids

  min_size = 2
  max_size = 5
  desired_capacity = 2

  load_balancers    = [aws_elb.sample.name]
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "terraform-asg-sample"
    propagate_at_launch = true
  }
}

resource "aws_elb" "sample" {
  name            = "${var.cluster_name}-asg-elb"
  security_groups = [aws_security_group.elb-sg.id]
  subnets         = data.aws_subnet_ids.selected.ids

  health_check {
    target              = "HTTP:${var.server_port}/"
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  # listener for incoming HTTP requests
  listener {
    lb_port           = var.elb_port
    lb_protocol       = "http"
    instance_port     = var.server_port
    instance_protocol = "http"
  }
}

resource "aws_subnet" "pub-b" {
  vpc_id            = data.aws_vpc.selected.id
  availability_zone = "us-west-2b"
  cidr_block        = "10.2.2.0/24"

  tags = {
    Name = "vpn-pub-b"
  }
}

resource "aws_subnet" "pub-c" {
  vpc_id            = data.aws_vpc.selected.id
  availability_zone = "us-west-2c"
  cidr_block        = "10.2.4.0/24"

  tags = {
    Name = "vpn-pub-c"
  }
}