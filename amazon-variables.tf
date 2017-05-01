variable "aws_region" {
    type = "string"
}

variable "aws_vpc" {
    type = "map"

    default = {
        name = ""
        cidr_block = ""
        enable_dns_support = ""
        enable_dns_hostnames = ""
    }
}

variable "aws_subnet" {
    type = "map"

    default = {
        pub_cidr_blocks = []
        prv_cidr_blocks = []
        pub_availability_zones = []
        prv_availability_zones = []
    }
}

variable "aws_instance" {
    type = "map"

    default = {
        instance_type = ""
        ami = ""
        key_name = ""
    }
}

