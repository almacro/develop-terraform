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
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.demo.id

  tags = {
    Name = "igw-demo"
  }
}

# Subnets, public
# create one per AZ
resource "aws_subnet" "public" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.demo.id
  cidr_block        = element(var.public_subnets_cidr, count.index)
  availability_zone = element(var.azs, count.index)

  map_public_ip_on_launch = true

  tags = {
    Name = "public-${count.index + 1}"
  }
}

# Subnets, private
# create one per AZ
resource "aws_subnet" "private" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.demo.id
  cidr_block        = element(var.private_subnets_cidr, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "private-${count.index + 1}"
  }
}

# dynamic list of public subnets created above
data "aws_subnet_ids" "public" {
  depends_on = [aws_subnet.public]
  vpc_id     = aws_vpc.demo.id
}

# dynamic list of private subnets created above
data "aws_subnet_ids" "private" {
  depends_on = [aws_subnet.private]
  vpc_id     = aws_vpc.demo.id
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

# associate Route Table with each Subnet
resource "aws_route_table_association" "demo" {
  count          = length(var.azs)
  subnet_id      = element(sort(data.aws_subnet_ids.public.ids), count.index)
  route_table_id = aws_route_table.demo.id
}

# create elastic IP (EIP) to assign to the NAT Gateway
resource "aws_eip" "demo_eip" {
  count      = length(var.azs)
  vpc        = true
  depends_on = [aws_internet_gateway.gw]
}

# create NAT Gateways
# NAT needs to be hosted in public, internet-facing subnet
resource "aws_nat_gateway" "demo" {
  count         = length(var.azs)
  allocation_id = element(aws_eip.demo_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  depends_on    = [aws_internet_gateway.gw]
}

# Route Table, private
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.demo.id
  count  = length(var.azs)

  tags = {
    Name = "rtb-private"
  }
}

resource "aws_route" "nat" {
  count                  = length(var.azs)
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  depends_on             = [aws_route_table.private]
  nat_gateway_id         = element(aws_nat_gateway.demo.*.id, count.index)
}
