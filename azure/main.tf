provider "azurerm" {
}

resource "azurerm_resource_group" "rg" {
    name = "${var.azr_vn["name"]}"
    location = "${var.azr_location}"

    tags {
        Name = "${var.azr_vn["name"]}"
        CreatedBy = "terraform"
    }
}

resource "azurerm_virtual_network" "vn" {
    name = "${var.azr_vn["name"]}"

    address_space = [ "${var.azr_vn["address_space"]}" ]
    location = "${azurerm_resource_group.rg.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    tags {
        Name = "${var.azr_vn["name"]}"
        CreatedBy = "terraform"
    }
}

resource "azurerm_route_table" "rt" {
    name = "${var.azr_location}"
    location = "${azurerm_virtual_network.vn.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_route" "pub" {
    name = "${var.azr_location} Pub"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    route_table_name = "${azurerm_route_table.rt.name}"

    address_prefix = "0.0.0.0/0"
    next_hop_type = "vnetlocal"
}

resource "azurerm_route" "prv" {
    name = "${var.azr_location} Prv"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    route_table_name = "${azurerm_route_table.rt.name}"

    address_prefix = "0.0.0.0/0"
    next_hop_type = "internet"
}

resource "azurerm_subnet" "pub" {
    count = "${length(var.azr_subnets["pub"])}"

    name = "Pub Subnet ${count.index}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    virtual_network_name = "${azurerm_virtual_network.vn.name}"
    route_table_id = "${azurerm_route_table.rt.id}"

    address_prefix = "${element(var.azr_subnets["pub"], count.index)}"
}

resource "azurerm_subnet" "prv" {
    count = "${length(var.azr_subnets["prv"])}"

    name = "Prv Subnet ${count.index}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    virtual_network_name = "${azurerm_virtual_network.vn.name}"
    route_table_id = "${azurerm_route_table.rt.id}"

    address_prefix = "${element(var.azr_subnets["prv"], count.index)}"
}

resource "azurerm_network_interface" "pub" {
    count = "${length(var.azr_subnets["pub"])}"

    name = "Pub Nic ${count.index}"
    location = "${var.azr_location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    ip_configuration {
        name = "NIC Pub"
        subnet_id = "${element(azurerm_subnet.pub.*.id, count.index)}"
        private_ip_address_allocation = "dynamic"
    }
}

resource "azurerm_network_interface" "prv" {
    count = "${length(var.azr_subnets["prv"])}"

    name = "Prv Nic ${count.index}"
    location = "${var.azr_location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    ip_configuration {
        name = "NIC Prv"
        subnet_id = "${element(azurerm_subnet.prv.*.id, count.index)}"
        private_ip_address_allocation = "dynamic"
    }
}

resource "azurerm_network_security_group" "sg" {
    name = "VPC Internal SSH"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    location = "${azurerm_resource_group.rg.location}"
}

resource "azurerm_network_security_rule" "bastion-ssh-inbound" {
    name = "Bastion inbound traffic"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    network_security_group_name = "${azurerm_network_security_group.sg.name}"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "22"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
}

resource "azurerm_network_security_rule" "bastion-ssh-outbound" {
    name = "Bastion outbound traffic"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    network_security_group_name = "${azurerm_network_security_group.sg.name}"
    priority = 100
    direction = "Outbound"
    access = "Allow"
    protocol = "*"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "*"
    destination_address_prefix = "*"
}

resource "azurerm_network_security_rule" "internal-inbound-traffic" {
    name = "Internal inbound traffic"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    network_security_group_name = "${azurerm_network_security_group.sg.name}"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "22"
    destination_port_range = "22"
    source_address_prefix = "${var.azr_vn["address_space"]}" #TODO: review this
    destination_address_prefix = "*"
}

resource "azurerm_network_security_rule" "internal-outbound-traffic" {
    name = "Internal outbound traffic"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    network_security_group_name = "${azurerm_network_security_group.sg.name}"
    priority = 100
    direction = "Outbound"
    access = "Allow"
    protocol = "*"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "*"
    destination_address_prefix = "*"
}

resource "azurerm_storage_account" "storage" {
    name                = "storage"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    location     = "${azurerm_resource_group.rg.location}"
    account_type = "${var.azr_storage_account["account_type"]}"

    tags {
        Name = "${azurerm_resource_group.rg.name}-storage"
        VN = "${azurerm_virtual_network.vn.tags.Name}"
        CreatedBy = "terraform"
    }
}

resource "azurerm_storage_container" "bastion" {
    name                  = "vhds"
    resource_group_name   = "${azurerm_resource_group.rg.name}"
    storage_account_name  = "${azurerm_storage_account.storage.name}"
    container_access_type = "private"
}

resource "azurerm_virtual_machine" "bastion" {
    name = "bastion"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    location = "${azurerm_resource_group.rg.location}"
    network_interface_ids = [ "${element(azurerm_network_interface.pub.*.id, 1)}" ]

    vm_size = "${var.azr_virtual_machine["vm_size"]}"

    storage_image_reference {
        publisher = "Canonical"
        offer = "UbuntuServer"
        sku = "16.04.2-LTS"
        version = "latest"
    }

    storage_os_disk {
        name = "bastion"
        vhd_uri = "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.bastion.name}/bastion.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "${var.azr_virtual_machine["computer_name"]}"
        admin_username = "${var.azr_virtual_machine["admin_username"]}"
        admin_password = "${var.azr_virtual_machine["admin_password"]}"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    tags {
        Name = "SSH Bastion"
        VN = "${azurerm_virtual_network.vn.tags.Name}"
        CreatedBy = "terraform"
    }
}

