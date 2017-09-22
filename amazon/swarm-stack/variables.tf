variable "aws_vpc" {
    type = "map"

    default = {
        name = ""
    }
}

variable "aws_subnet" {
    type = "map"

    default = {
        cidr_blocks = []
        ids = []
    }
}

variable "aws_security_group" {
    type = "map"

    default = {
        internal = ""
        instance = ""
    }
}

variable "aws_swarm_mgr_instance" {
    type = "map"

    default = {
        count = 0
        instance_type = ""
        ami = ""
        key_name = ""
        name = ""
    }
}

variable "aws_swarm_wkr_instance" {
    type = "map"

    default = {
        count = 0
        instance_type = ""
        ami = ""
        key_name = ""
        name = ""
    }
}

