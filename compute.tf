provider "aws" {
  region = "eu-west-2"
}

# ============ EC2 INSTANCES ============
resource "aws_instance" "jenkins_server" {
  ami                         = var.jenkins_server.ami
  instance_type               = var.jenkins_server.instance_type
  availability_zone           = var.jenkins_server.availability_zone

  key_name                    = var.jenkins_server.ssh_key

  subnet_id                   = aws_subnet.subnet[var.node_server.subnet].id
  vpc_security_group_ids      = [for sg in var.jenkins_server.security_groups : aws_security_group.sg[sg].id]
  associate_public_ip_address = true

  user_data = file(var.jenkins_server.user_data)

  tags = {
    Name = var.jenkins_server.name
  }
}

resource "aws_instance" "node_server" {
  ami                         = var.node_server.ami
  instance_type               = var.node_server.instance_type
  availability_zone           = var.node_server.availability_zone

  key_name                    = var.node_server.ssh_key

  subnet_id                   = aws_subnet.subnet[var.node_server.subnet].id
  vpc_security_group_ids      = [for sg in var.node_server.security_groups : aws_security_group.sg[sg].id]
  associate_public_ip_address = true

  user_data = templatefile(var.node_server.user_data, {
    db_ip = aws_instance.database.private_ip
  })

  tags = {
    Name = var.node_server.name
  }

  depends_on         = [aws_instance.database]

}

resource "aws_instance" "monitoring_server" {
  ami                         = var.monitoring_server.ami
  instance_type               = var.monitoring_server.instance_type
  availability_zone           = var.monitoring_server.availability_zone

  key_name                    = var.monitoring_server.ssh_key
  
  subnet_id                   = aws_subnet.subnet[var.monitoring_server.subnet].id
  vpc_security_group_ids      = [for sg in var.monitoring_server.security_groups : aws_security_group.sg[sg].id]

  user_data = file(var.monitoring_server.user_data)

  tags = {
    Name = var.monitoring_server.name
  }
}

resource "aws_instance" "database" {
    ami                     = var.db.ami
    instance_type           = var.db.instance_type
    availability_zone       = var.db.availability_zone
  
    key_name                = var.db.ssh_key


    subnet_id = aws_subnet.subnet[var.db.subnet].id
    vpc_security_group_ids = [for sg in var.db.security_groups : aws_security_group.sg[sg].id]    
    associate_public_ip_address = true
    
    user_data = file("db_setup.sh")
    
    tags = {
        Name = var.db.name
    }
}

# ============ LOAD BALANCER ============
resource "aws_lb" "app_lb" {
  name               = var.alb.name
  internal           = false
  load_balancer_type = var.alb.load_balancer_type
  security_groups    = [for sg in var.alb.security_groups : aws_security_group.sg[sg].id] 


  subnets            = [aws_subnet.subnet[var.alb.subnet_1].id, aws_subnet.subnet[var.alb.subnet_2].id]
  depends_on         = [
    aws_internet_gateway.gw,
    aws_instance.database
  ]
}

resource "aws_lb_target_group" "app_tg" {
  name              = var.alb_target_group.name
  port              = var.alb_target_group.port
  protocol          = var.alb_target_group.protocol
  vpc_id            = aws_vpc.app-vpc.id
}


resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = var.alb_listener.port
  protocol          = var.alb_listener.protocol
  default_action {
    type             = var.alb_listener.da_type
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# ============ LAUNCH TEMPLATE ============
resource "aws_launch_template" "app" {
  name_prefix                   = var.node_server.name
  image_id                      = var.node_server.ami
  instance_type                 = var.node_server.instance_type
  user_data                     = base64encode(templatefile(var.node_server.user_data, {
    db_ip = aws_instance.database.private_ip
  }))

  network_interfaces {
    associate_public_ip_address = false
    subnet_id                   = aws_subnet.subnet[var.node_server.subnet].id
    security_groups             = [for sg in var.node_server.security_groups : aws_security_group.sg[sg].id] 
 
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "woc-app"
    }
  }
}

# ============ AUTOSCALING GROUP ============
resource "aws_autoscaling_group" "app_asg" {
  # no of instances
  desired_capacity = 2
  max_size         = 3
  min_size         = 2

  # Connect to the target group
  target_group_arns = [aws_lb_target_group.app_tg.arn]

  vpc_zone_identifier = [ # Creating EC2 instances in private subnet
    aws_subnet.subnet["private"].id
  ]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
}
