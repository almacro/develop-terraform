# Security Group
resource "aws_security_group" "docker_demo_ec2" {
  name        = "Docker-Nginx-Demo-EC2"
  description = "Allow incoming HTTP traffic only"
  vpc_id      = aws_vpc.demo.id
}

resource "aws_security_group_rule" "allow_ssh_in" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.docker_demo_ec2.id
}

resource "aws_security_group_rule" "allow_http_in" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.docker_demo_ec2.id
}

resource "aws_security_group_rule" "allow_all_out" {
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.docker_demo_ec2.id
}

resource "aws_instance" "docker_demo" {
  ami           = lookup(var.ec2_amis, var.aws_region)
  count         = length(var.azs)
  depends_on    = ["aws_subnet.private"]
  instance_type = "t3a.micro"
  subnet_id     = element(aws_subnet.private.*.id, count.index)
  user_data     = file("user_data.sh")

  vpc_security_group_ids = [aws_security_group.docker_demo_ec2.id]

  tags = {
    Name = "docker-nginx-demo-instance-${count.index}"
  }
}
