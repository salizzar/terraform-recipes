resource "azurerm_public_ip" "mgr" {
    count                           = "${var.azurerm_swarm_mgr_virtual_machine["count"]}"

    name                            = "swarm-mgr-${count.index}"
    resource_group_name             = "${var.azurerm_resource_group["name"]}"
    location                        = "${var.azurerm_resource_group["location"]}"
    public_ip_address_allocation    = "dynamic"

    tags {
        VirtualNetwork  = "${var.azurerm_virtual_network["name"]}"
        CreatedBy       = "terraform"
    }
}

resource "azurerm_network_interface" "mgr" {
    count = "${var.azurerm_swarm_mgr_virtual_machine["count"]}"

    name = "swarm_mgr_nic_${count.index}"
    location = "${var.azurerm_resource_group["location"]}"
    resource_group_name = "${var.azurerm_resource_group["name"]}"

    ip_configuration {
        name = "swarm_mgr_nic_${count.index}"
        subnet_id = "${element(var.azurerm_subnet["ids"], count.index)}"
        public_ip_address_id = "${element(azurerm_public_ip.mgr.*.id, count.index)}"
        private_ip_address_allocation = "dynamic"
    }
}

resource "azurerm_virtual_machine" "mgr" {
    count = "${var.azurerm_swarm_mgr_virtual_machine["count"]}"

    name = "swarm-mgr-${count.index}"
    resource_group_name = "${var.azurerm_resource_group["name"]}"
    location = "${var.azurerm_resource_group["location"]}"
    network_interface_ids = [ "${element(azurerm_network_interface.mgr.*.id, count.index)}" ]

    vm_size = "${var.azurerm_swarm_mgr_virtual_machine["vm_size"]}"

    storage_image_reference {
        publisher = "${var.azurerm_swarm_mgr_virtual_machine["storage_image_reference_publisher"]}"
        offer = "${var.azurerm_swarm_mgr_virtual_machine["storage_image_reference_offer"]}"
        sku = "${var.azurerm_swarm_mgr_virtual_machine["storage_image_reference_sku"]}"
        version = "${var.azurerm_swarm_mgr_virtual_machine["storage_image_reference_version"]}"
    }

    storage_os_disk {
        name = "swarm-mgr-${count.index}"
        vhd_uri = "${var.azurerm_storage_account["primary_blob_endpoint"]}${var.azurerm_storage_container["name"]}/swarm-mgr-${count.index}.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "swarm-mgr-${count.index}"
        admin_username = "ubuntu"
    }

    os_profile_linux_config {
        disable_password_authentication = true

        ssh_keys {
            path = "/home/ubuntu/.ssh/authorized_keys"
            key_data = "${file("~/.ssh/azr.pub")}"
        }
    }

    tags {
        Name = "${var.azurerm_swarm_mgr_virtual_machine["name"]}-${count.index}"
        VirtualNetwork = "${var.azurerm_virtual_network["name"]}"
        CreatedBy = "terraform"
    }
}

resource "azurerm_public_ip" "wkr" {
    count                           = "${var.azurerm_swarm_wkr_virtual_machine["count"]}"

    name                            = "swarm-wkr-${count.index}"
    resource_group_name             = "${var.azurerm_resource_group["name"]}"
    location                        = "${var.azurerm_resource_group["location"]}"
    public_ip_address_allocation    = "dynamic"

    tags {
        VirtualNetwork  = "${var.azurerm_virtual_network["name"]}"
        CreatedBy       = "terraform"
    }
}

resource "azurerm_network_interface" "wkr" {
    count = "${var.azurerm_swarm_wkr_virtual_machine["count"]}"

    name = "swarm_wkr_nic_${count.index}"
    location = "${var.azurerm_resource_group["location"]}"
    resource_group_name = "${var.azurerm_resource_group["name"]}"

    ip_configuration {
        name = "swarm_wkr_nic_${count.index}"
        subnet_id = "${element(var.azurerm_subnet["ids"], count.index)}"
        public_ip_address_id = "${element(azurerm_public_ip.wkr.*.id, count.index)}"
        private_ip_address_allocation = "dynamic"
    }
}

resource "azurerm_virtual_machine" "wkr" {
    count = "${var.azurerm_swarm_wkr_virtual_machine["count"]}"

    name = "swarm-wkr-${count.index}"
    resource_group_name = "${var.azurerm_resource_group["name"]}"
    location = "${var.azurerm_resource_group["location"]}"
    network_interface_ids = [ "${element(azurerm_network_interface.wkr.*.id, count.index)}" ]

    vm_size = "${var.azurerm_swarm_wkr_virtual_machine["vm_size"]}"

    storage_image_reference {
        publisher = "${var.azurerm_swarm_wkr_virtual_machine["storage_image_reference_publisher"]}"
        offer = "${var.azurerm_swarm_wkr_virtual_machine["storage_image_reference_offer"]}"
        sku = "${var.azurerm_swarm_wkr_virtual_machine["storage_image_reference_sku"]}"
        version = "${var.azurerm_swarm_wkr_virtual_machine["storage_image_reference_version"]}"
    }

    storage_os_disk {
        name = "swarm-wkr-${count.index}"
        vhd_uri = "${var.azurerm_storage_account["primary_blob_endpoint"]}${var.azurerm_storage_container["name"]}/swarm-wkr-${count.index}.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "swarm-wkr-${count.index}"
        admin_username = "ubuntu"
    }

    os_profile_linux_config {
        disable_password_authentication = true

        ssh_keys {
            path = "/home/ubuntu/.ssh/authorized_keys"
            key_data = "${file("~/.ssh/azr.pub")}"
        }
    }

    tags {
        Name = "${var.azurerm_swarm_wkr_virtual_machine["name"]}-${count.index}"
        VirtualNetwork = "${var.azurerm_virtual_network["name"]}"
        CreatedBy = "terraform"
    }
}

