variable "azr_location" {
    type = "string"
}

variable "azr_vn" {
    type = "map"

    default = {
        name = ""
        address_space = ""
    }
}

variable "azr_subnets" {
    type = "map"

    default = {
        pub_cidr_blocks = []
        prv_cidr_blocks = []
    }
}

variable "azr_virtual_machine" {
    type = "map"

    default = {
        vm_size = ""
        admin_username = ""
        admin_password = ""
    }
}

variable "azr_storage_account" {
    type = "map"

    default = {
        name = ""
        account_type = ""
    }
}

