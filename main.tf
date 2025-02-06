provider "aws" {
  region = "eu-west-2"
}

# ==== NETWORKING ====
resource "aws_vpc" "app-vpc" {
  cidr_block = var.vpc.cidr_block
  
  tags = {
    Name = var.vpc.name
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.app-vpc.id
}

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

resource "aws_subnet" "jenkins-subnet" {
  vpc_id            = aws_vpc.app-vpc.id
  cidr_block        = var.jenkins_subnet.cidr_block
  availability_zone = var.jenkins_subnet.availability_zone
  
  tags = {
    Name = var.jenkins_subnet.name
  }
}

# ====== ASSOCIATE SUBNET WITH ROUTE TABLE ======
resource "aws_route_table_association" "a" {
  subnet_id       = aws_subnet.jenkins-subnet.id
  route_table_id  = aws_route_table.app-route-table.id
}
 
resource "aws_security_group" "jenkins_sg" {
  name        = var.jenkins_sg.name
  description = var.jenkins_sg.description
  vpc_id      = aws_vpc.app-vpc.id
  
  dynamic "ingress" {
    # iterate over dynamic ingress values to create ingress rules
    for_each = var.jenkins_sg.ingress
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
    Name = var.jenkins_sg.tag
  }
}

# ====== EC2 INSTANCE ======
resource "aws_instance" "jenkins_server" {
  ami                         = var.jenkins_server.ami
  instance_type               = var.jenkins_server.instance_type
  availability_zone           = var.jenkins_server.availability_zone

  key_name                    = var.jenkins_server.ssh_key

  subnet_id                   = aws_subnet.jenkins-subnet.id
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  associate_public_ip_address = true

  user_data = file(var.jenkins_server.user_data)

  tags = {
    Name = var.jenkins_server.name
  }

}

resource "null_resource" "run_ansible" {
  depends_on = [aws_instance.jenkins_server]

  provisioner "local-exec" {
    command = "sleep 120 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${aws_instance.jenkins_server.public_ip},' --private-key=${var.jenkins_account.private_key} -u ${var.jenkins_account.username} ${var.jenkins_account.playbook}"
  }
}