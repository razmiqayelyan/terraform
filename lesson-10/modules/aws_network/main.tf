# ------------------ Availability Zones ------------------
data "aws_availability_zones" "available" {
  state = "available"
}

# ------------------ VPC ------------------
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.env}-VPC"
  }
}

# ------------------ Internet Gateway ------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}-IGW"
  }
}

# ------------------ Public Subnets ------------------
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_cidr_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_cidr_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env}-public-${count.index + 1}"
  }
}

# ------------------ Route Table for Public Subnets ------------------
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.env}-route-public-subnets"
  }
}

resource "aws_route_table_association" "public_routes" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# ------------------ Elastic IPs for NAT ------------------
resource "aws_eip" "nat" {
  count  = length(var.private_subnet_cidrs)
  domain = "vpc"
  tags = {
    Name = "${var.env}-nat-eip-${count.index + 1}"
  }
}


# ------------------ NAT Gateways ------------------
resource "aws_nat_gateway" "nat" {
  count         = length(var.private_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id

  tags = {
    Name = "${var.env}-nat-gw-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.main]
}

# ------------------ Private Subnets ------------------
resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.env}-private-${count.index + 1}"
  }
}

# ------------------ Route Table for Private Subnets ------------------
resource "aws_route_table" "private_subnets" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = {
    Name = "${var.env}-route-private-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_routes" {
  count          = length(aws_subnet.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_subnets[count.index].id
}
