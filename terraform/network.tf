resource "aws_vpc" "default" {
  cidr_block = "172.31.0.0/16"
}

resource "aws_subnet" "public_1a" {
  vpc_id     = aws_vpc.default.id
  cidr_block = "172.31.80.0/20"
}

resource "aws_subnet" "public_1b" {
  vpc_id     = aws_vpc.default.id
  cidr_block = "172.31.16.0/20"
}

resource "aws_subnet" "public_1c" {
  vpc_id     = aws_vpc.default.id
  cidr_block = "172.31.32.0/20"
}

resource "aws_subnet" "public_1d" {
  vpc_id     = aws_vpc.default.id
  cidr_block = "172.31.0.0/20"
}

resource "aws_subnet" "public_1e" {
  vpc_id     = aws_vpc.default.id
  cidr_block = "172.31.64.0/20"
}

resource "aws_subnet" "public_1f" {
  vpc_id     = aws_vpc.default.id
  cidr_block = "172.31.48.0/20"
}

locals {
  subnet_ids = {
    public_1a = aws_subnet.public_1a.id
    public_1b = aws_subnet.public_1b.id
    public_1c = aws_subnet.public_1c.id
    public_1d = aws_subnet.public_1d.id
    public_1e = aws_subnet.public_1e.id
    public_1f = aws_subnet.public_1f.id
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "172.31.0.0/16"
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route_table_association" "subnet" {
  for_each       = local.subnet_ids
  subnet_id      = each.value
  route_table_id = aws_route_table.main.id
}
