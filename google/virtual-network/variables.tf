variable "gce_region" {
    type = "string"
}

variable "gce_network" {
    type = "map"

    default = {
        name = ""
        description = ""
    }
}

variable "gce_subnets" {
    type = "map"

    default = {
        pub_cidr_blocks = []
        prv_cidr_blocks = []
    }
}

variable "gce_instance" {
    type = "map"

    default = {
        disk_image = ""
        machine_type = ""
    }
}
