# ========  VPC ========
variable "vpc" {
    type = object({
        name = string
        cidr_block = string
    })
}

# ========  ROUTE TABLE ========
variable "route_table" {
    type = object({
        name = string
        ip4_cidr_block = string
        ipv6_cidr_block = string
    })
}


# ========  ROUTE TABLE ========
variable "subnets" {
    type = map(object({
        name                = string
        cidr_block          = string
        availability_zone   = string
    }))
}

variable "security_groups" {
    type = map(object({
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
    }))
}
