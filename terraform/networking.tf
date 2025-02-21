# ========  VPC ========
resource "aws_vpc" "app-vpc" {
  cidr_block = var.vpc.cidr_block
  
  tags = {
    Name = var.vpc.name
  }
}

# ========  INTERNET GATEWAY ========
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.app-vpc.id
}

# ========  ROUTE TABLE ========
resource "aws_route_table" "app-route-table" {
  vpc_id = aws_vpc.app-vpc.id

  route {
    cidr_block      = var.route_table.ip4_cidr_block
    gateway_id      = aws_internet_gateway.gw.id
  }
  route {
    ipv6_cidr_block = var.route_table.ipv6_cidr_block
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name  = var.route_table.name
  }
}

# ====== CREATE PUBLIC SUBNETS ======
resource "aws_subnet" "subnet" {
  for_each = var.subnets

  vpc_id            = aws_vpc.app-vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  
  tags = {
    Name = each.value.name
  }
}

# ====== ASSOCIATE SUBNET WITH ROUTE TABLE ======
resource "aws_route_table_association" "rta" {
  for_each        = aws_subnet.subnet

  subnet_id       = each.value.id
  route_table_id  = aws_route_table.app-route-table.id

}

# ====== CREATE SECURITY GROUPS ======
resource "aws_security_group" "sg" {
  for_each = var.security_groups 
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.app-vpc.id
  
  dynamic "ingress" {
    # iterate over dynamic ingress values to create ingress rules
    for_each = each.value.ingress
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = each.value.tag
  }
}
