# VPC
resource "aws_vpc" "demo" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-demo"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "demo" {
  vpc_id = aws_vpc.demo.id

  tags = {
    Name = "igw-demo"
  }
}

# Subnet, public
# create one per AZ
resource "aws_subnet" "public" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.demo.id
  cidr_block        = "10.20.${count.index}.0/24"
  availability_zone = element(var.azs, count.index)

  map_public_ip_on_launch = true

  tags = {
    Name = "public-${count.index + 1}"
  }
}

# dynamic list of subnets created above
data "aws_subnet_ids" "public" {
  depends_on = [aws_subnet.public]
  vpc_id     = aws_vpc.demo.id
}

# Route Table
resource "aws_route_table" "demo" {
  vpc_id = aws_vpc.demo.id

  tags = {
    Name = "rtb-demo"
  }
}

# Route for public gateway
resource "aws_route" "public" {
  gateway_id             = aws_internet_gateway.demo.id
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.demo.id
}

# associate Route Table with VPC
resource "aws_main_route_table_association" "demo" {
  vpc_id         = aws_vpc.demo.id
  route_table_id = aws_route_table.demo.id
}

# associate Route Table with each Subnet
resource "aws_route_table_association" "demo" {
  count          = length(var.azs)
  subnet_id      = element(sort(data.aws_subnet_ids.public.ids), count.index)
  route_table_id = aws_route_table.demo.id
}
