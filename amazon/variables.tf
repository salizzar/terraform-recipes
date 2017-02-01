variable "aws_region" {
    type = "string"
}

variable "aws_vpc" {
    type = "map"

    default = {
        cidr_block = ""
        enable_dns_support = ""
        enable_dns_hostnames = ""
    }
}

variable "aws_subnet" {
    type = "map"

    default = {
        pub_1_cidr_block = ""
        pub_1_availability_zone = ""

        pub_2_cidr_block = ""
        pub_2_availability_zone = ""

        pub_3_cidr_block = ""
        pub_3_availability_zone = ""

        prv_1_cidr_block = ""
        prv_1_availability_zone = ""

        prv_2_cidr_block = ""
        prv_2_availability_zone = ""

        prv_3_cidr_block = ""
        prv_3_availability_zone = ""
    }
}

variable "aws_route" {
    type = "map"

    default = {
        destination_cidr_block = ""
    }
}

