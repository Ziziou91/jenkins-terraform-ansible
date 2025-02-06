provider "aws" {
  region = "eu-west-2"
}

# ==== NETWORKING ====
resource "aws_vpc" "app-vpc" {
  cidr_block = var.vpc_cidr_block
  
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.app-vpc.id
}

resource "aws_route_table" "app-route-table" {
  vpc_id = aws_vpc.app-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name  = var.route_table_name
  }
}

resource "aws_subnet" "jenkins-subnet" {
  vpc_id     = aws_vpc.app-vpc.id
  cidr_block = var.jenkins_subnet_cidr_block
  availability_zone = "eu-west-2a"
  
  tags = {
    Name = var.jenkins_subnet_name
  }
}

resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.jenkins-subnet.id
  route_table_id = aws_route_table.app-route-table.id
}
 
resource "aws_security_group" "jenkins_sg" {
  name        = var.jenkins_sg_name
  description = "Allow Jenkins and SSH access"
  vpc_id      = aws_vpc.app-vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}

# ==== EC2 INSTANCE ====
resource "aws_instance" "jenkins_server" {
  ami           = var.jenkins_server_ami
  instance_type = "t2.micro"
  availability_zone = "eu-west-2a"


  key_name      = var.jenkins_server_ssh_key

  subnet_id                   = aws_subnet.jenkins-subnet.id
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  associate_public_ip_address = true

  # User data script to install Ansible and Jenkins
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              
              # Install Python
              yum install -y python3 python3-pip

              EOF

  tags = {
    Name = "Jenkins-Ansible-Server"
  }

}



resource "null_resource" "run_ansible" {
  depends_on = [aws_instance.jenkins_server]

  provisioner "local-exec" {
    command = "sleep 120 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${aws_instance.jenkins_server.public_ip},' --private-key=${var.jenkins_server_private_key} -u ${var.jenkins_server_username} ${var.ansible_playbook}"
  }
}