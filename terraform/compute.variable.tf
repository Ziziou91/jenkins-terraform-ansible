# =============APPLICATION LOAD BALANCER=============
variable "alb" {
    type = object({
        name                = string
        load_balancer_type  = string
        security_groups     = list(string)
        subnet_1              = string    
        subnet_2              = string    
    })
}

variable "alb_target_group" {
    type = object({
        name                = string
        port                = number
        protocol            = string
        hc_path             = string
        hc_port             = string
    })
}

variable "alb_listener" {
    type = object({
        port                = number
        protocol            = string
        da_type             = string
    })
}


# =============EC2 INSTANCES=============
variable "jenkins_server" {
    type = object({
        name                = string
        ami                 = string
        availability_zone   = string
        instance_type       = string
        user_data           = string
        ssh_key             = string
        security_groups     = list(string)
        subnet              = string    

    })
}

variable "node_server" {
    type = object({
        name                = string
        ami                 = string
        availability_zone   = string
        instance_type       = string
        user_data           = string
        ssh_key             = string
        security_groups = list(string)
        subnet              = string    

    })
}

variable "monitoring_server" {
    type = object({
        name                = string
        ami                 = string
        availability_zone   = string
        instance_type       = string
        user_data           = string
        ssh_key             = string
        security_groups = list(string)
        subnet              = string    

    })
}

variable "db" {
    type = object({
        name                = string
        ami                 = string
        availability_zone   = string
        instance_type       = string
        ssh_key             = string
        security_groups     = list(string)
        subnet              = string
    })
}

variable "jenkins_account"  {
    type = object({
        private_key = string
        username    = string
        playbook    = string
    })
}

variable "docker_playbook" {
    type = string
}

variable "monitoring_playbook" {
    type = string
}