variable "vpc" {
    type = object({
        name = string
        cidr_block = string
    })
}

variable "route_table" {
    type = object({
        name = string
        ip4_cidr_block = string
        ipv6_cidr_block = string
    })
}

variable "jenkins_subnet" {
    type = object({
        name                = string
        cidr_block          = string
        availability_zone   = string
    })
}

variable "jenkins_sg" {
    type = object({
        name = string
        description = string

        ingress = list(object({
            description = string
            from_port = number
            to_port = number
            protocol = string
            cidr_blocks = list(string)
        }))

        tag = string
    })
}

variable "jenkins_server" {
    type = object({
        name                = string
        ami                 = string
        availability_zone   = string
        instance_type       = string
        user_data           = string
        ssh_key             = string
    })
}

variable "jenkins_account"  {
    type = object({
        private_key = string
        username    = string
        playbook    = string
    })
}
