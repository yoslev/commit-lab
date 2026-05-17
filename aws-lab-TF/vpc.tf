# vpc.tf

resource "aws_vpc" "lab" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "lab-vpc"
  }
}

# SUBNETS
resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false

  tags = {
    Name = "lab-private-a"
    # AWS recommends tagging subnets for LB discovery, Without following tags, AWS LB Controller may not know where to create the internal ALB.
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/lab-eks"   = "shared"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = false

  tags = {
    Name = "lab-private-b"
    # AWS recommends tagging subnets for LB discovery, Without following tags, AWS LB Controller may not know where to create the internal ALB.
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/lab-eks"   = "shared"
  }
}

# ROUTE TABLE
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.lab.id

  tags = {
    Name = "lab-private-rt"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}
