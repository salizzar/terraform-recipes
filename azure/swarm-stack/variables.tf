variable "azurerm_resource_group" {
    type = "map"

    default = {
        name = ""
        location = ""
    }
}

variable "azurerm_virtual_network" {
    type = "map"

    default = {
        name = ""
    }
}

variable "azurerm_subnet" {
    type = "map"

    default = {
        ids = []
    }
}

variable "azurerm_storage_account" {
    type = "map"

    default = {
        primary_blob_endpoint = ""
    }
}

variable "azurerm_storage_container" {
    type = "map"

    default = {
        name = ""
    }
}

variable "azurerm_swarm_mgr_virtual_machine" {
    type = "map"

    default = {
        count = 0
        vm_size = 0

        storage_image_reference_publisher = ""
        storage_image_reference_offer = ""
        storage_image_reference_sku = ""
        storage_image_reference_version = ""
    }
}

variable "azurerm_swarm_wkr_virtual_machine" {
    type = "map"

    default = {
        count = 0
        vm_size = 0

        storage_image_reference_publisher = ""
        storage_image_reference_offer = ""
        storage_image_reference_sku = ""
        storage_image_reference_version = ""
    }
}

