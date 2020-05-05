# VPC
resource "aws_vpc" "demo" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-demo"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.demo.id

  tags = {
    Name = "igw-demo"
  }
}

# Subnets, public
# create one per AZ
resource "aws_subnet" "public" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.demo.id
  cidr_block        = element(var.public_subnets_cidr, count.index)
  availability_zone = element(var.availability_zones, count.index)

  map_public_ip_on_launch = true

  tags = {
    Name = "public-${count.index + 1}"
  }
}

# Subnets, private
# create one per AZ
resource "aws_subnet" "private" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.demo.id
  cidr_block        = element(var.private_subnets_cidr, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "private-${count.index + 1}"
  }
}

# dynamic list of public subnets created above
data "aws_subnet_ids" "public" {
  depends_on = [aws_subnet.public]
  vpc_id     = aws_vpc.demo.id
  filter {
    name   = "tag:Name"
    values = ["public-1", "public-2", "public-3"]
  }
}

# dynamic list of private subnets created above
data "aws_subnet_ids" "private" {
  depends_on = [aws_subnet.private]
  vpc_id     = aws_vpc.demo.id
  filter {
    name   = "tag:Name"
    values = ["private-1", "private-2", "private-3"]
  }
}

# Route Table, public
resource "aws_route_table" "demo" {
  vpc_id = aws_vpc.demo.id

  tags = {
    Name = "rtb-demo"
  }
}

# Route for public gateway
resource "aws_route" "public" {
  gateway_id             = aws_internet_gateway.gw.id
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.demo.id
}

# associate Route Table with VPC
resource "aws_main_route_table_association" "demo" {
  vpc_id         = aws_vpc.demo.id
  route_table_id = aws_route_table.demo.id
}

# associate Route Table with each public Subnet
resource "aws_route_table_association" "demo" {
  count          = length(var.availability_zones)
  subnet_id      = element(sort(data.aws_subnet_ids.public.ids), count.index)
  route_table_id = aws_route_table.demo.id
}

resource "aws_security_group" "nat" {
  name_prefix = var.nat_name
  vpc_id      = aws_vpc.demo.id
  description = "Security Group for NAT instance"

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = var.private_subnets_cidr
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Role = "NAT"
  }
}

resource "aws_network_interface" "nat" {
  security_groups   = [aws_security_group.nat.id]
  subnet_id         = element(sort(data.aws_subnet_ids.public.ids), 0)
  source_dest_check = false
  description       = "ENI for NAT instance"
}

resource "aws_eip" "nat" {
  network_interface = aws_network_interface.nat.id
}

data "aws_ami" "aml" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }
}

resource "aws_key_pair" "terraform-demo" {
  key_name   = "terraform-demo"
  public_key = file("terraform-demo.pub")
}

resource "aws_launch_template" "nat" {
  name_prefix = var.nat_name
  image_id    = data.aws_ami.aml.id
  key_name    = aws_key_pair.terraform-demo.key_name
  iam_instance_profile {
    arn = aws_iam_instance_profile.nat.arn
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.nat.id]
    delete_on_termination       = true
  }
  user_data = base64encode(
    templatefile("init.sh", {
      eni_id          = aws_network_interface.nat.id
      extra_user_data = var.extra_user_data
    })
  )

  description = "Launch template for NAT instance"
  tags = {
    Name = "ec2-nat-instance"
  }
}

resource "aws_autoscaling_group" "nat" {
  name_prefix         = var.nat_name
  desired_capacity    = 1
  min_size            = 1
  max_size            = 1
  vpc_zone_identifier = [element(sort(data.aws_subnet_ids.public.ids), 0)]

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
    }
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.nat.id
        version            = "$Latest"
      }
      dynamic "override" {
        for_each = var.instance_types
        content {
          instance_type = override.value
        }
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "nat" {
  name_prefix = var.nat_name
  role        = aws_iam_role.nat.name
}

resource "aws_iam_role" "nat" {
  name_prefix        = var.nat_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "eni" {
  role        = aws_iam_role.nat.name
  name_prefix = var.nat_name
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AttachNetworkInterface"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Route Table, private
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.demo.id
  count  = length(var.availability_zones)

  tags = {
    Name = "rtb-private-${count.index + 1}"
  }
}

resource "aws_route" "nat" {
  count                  = length(var.availability_zones)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  depends_on             = [aws_route_table.private]
  network_interface_id   = aws_network_interface.nat.id
}

resource "aws_route_table_association" "nat" {
  count          = length(var.availability_zones)
  subnet_id      = element(sort(data.aws_subnet_ids.private.ids), count.index)
  route_table_id = aws_route_table.private[count.index].id
}
