variable "aws_region" {
  default = "us-west-2"
}

provider "aws" {
  region = var.aws_region
}

# vpc
data "aws_vpc" "selected" {
  tags = {
    Name = "vpc-tutor"
  }
}

data "aws_security_group" "nat" {
  tags = {
    Role = "NAT"
  }
}

data "aws_subnet" "private" {
  vpc_id = data.aws_vpc.selected.id
  tags = {
    Name = "private-1"
  }
}

# sec grp
resource "aws_security_group" "instance" {
  name   = "ec2-nat-testing-sg"
  vpc_id = data.aws_vpc.selected.id
}

resource "aws_security_group_rule" "allow_ssh_in" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.instance.id
}

resource "aws_security_group_rule" "allow_all_out" {
  type      = "egress"
  protocol  = "-1"
  from_port = 0
  to_port   = 0

  security_group_id        = aws_security_group.instance.id
  source_security_group_id = data.aws_security_group.nat.id
}

# ec2
resource "aws_instance" "test" {
  ami                    = "ami-09eb6a1f3d27274e5"
  instance_type          = "t3a.nano"
  key_name               = "terraform-demo"
  subnet_id              = data.aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.instance.id]
}

# outputs
output "outputs" {
  value = {
    selected_vpc         = data.aws_vpc.selected.*.id,
    selected_sg_nat      = data.aws_security_group.nat.id,
    created_sg_instance  = aws_security_group.instance.id,
    created_ec2_instance = aws_instance.test.id
  }
}
