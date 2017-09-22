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

# route table to be used by subnets

resource "azurerm_route_table" "rt" {
    name = "${var.azr_location}"
    location = "${azurerm_virtual_network.vn.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
}

# public route

resource "azurerm_route" "pub" {
    name = "${var.azr_location}_pub"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    route_table_name = "${azurerm_route_table.rt.name}"

    address_prefix = "${var.azr_vn["address_space"]}"
    next_hop_type = "vnetlocal"
}

# private route

resource "azurerm_route" "prv" {
    name = "${var.azr_location}_prv"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    route_table_name = "${azurerm_route_table.rt.name}"

    address_prefix = "0.0.0.0/0"
    next_hop_type = "internet"
}

# public subnets

resource "azurerm_subnet" "pub" {
    count = "${length(var.azr_subnets["pub_cidr_blocks"])}"

    name = "pub_subnet_${count.index}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    virtual_network_name = "${azurerm_virtual_network.vn.name}"
    route_table_id = "${azurerm_route_table.rt.id}"

    address_prefix = "${element(var.azr_subnets["pub_cidr_blocks"], count.index)}"
}

# private subnets

resource "azurerm_subnet" "prv" {
    count = "${length(var.azr_subnets["prv_cidr_blocks"])}"

    name = "prv_subnet_${count.index}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    virtual_network_name = "${azurerm_virtual_network.vn.name}"
    route_table_id = "${azurerm_route_table.rt.id}"

    address_prefix = "${element(var.azr_subnets["prv_cidr_blocks"], count.index)}"
}

# internal security group

resource "azurerm_network_security_group" "sg" {
    name = "VPC_Internal_SSH"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    location = "${azurerm_resource_group.rg.location}"
}

# bastion ingress security group rules

resource "azurerm_network_security_rule" "bastion-ssh-inbound" {
    name = "Bastion_Inbound_Traffic"
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

# bastion egress security group rules

resource "azurerm_network_security_rule" "bastion-ssh-outbound" {
    name = "Bastion_Outbound_Traffic"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    network_security_group_name = "${azurerm_network_security_group.sg.name}"
    priority = 101
    direction = "Outbound"
    access = "Allow"
    protocol = "*"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "*"
    destination_address_prefix = "*"
}

# internal ingress security group rules

resource "azurerm_network_security_rule" "internal-inbound-traffic" {
    name = "Internal_Inbound_Traffic"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    network_security_group_name = "${azurerm_network_security_group.sg.name}"
    priority = 102
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "22"
    destination_port_range = "22"
    source_address_prefix = "${azurerm_network_interface.bastion.private_ip_address}/32"
    destination_address_prefix = "*"
}

# storage to vms

resource "azurerm_storage_account" "storage" {
    name                = "${var.azr_storage_account["name"]}"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    location     = "${azurerm_resource_group.rg.location}"
    account_type = "${var.azr_storage_account["account_type"]}"

    tags {
        VirtualNetwork = "${azurerm_virtual_network.vn.tags.Name}"
        CreatedBy = "terraform"
    }
}

resource "azurerm_storage_container" "vhds" {
    name                  = "vhds"
    resource_group_name   = "${azurerm_resource_group.rg.name}"
    storage_account_name  = "${azurerm_storage_account.storage.name}"
    container_access_type = "private"
}

# bastion server

resource "azurerm_public_ip" "bastion" {
    name                            = "bastion"
    resource_group_name             = "${azurerm_resource_group.rg.name}"
    location                        = "${azurerm_resource_group.rg.location}"
    public_ip_address_allocation    = "dynamic"

    tags {
        VirtualNetwork  = "${azurerm_virtual_network.vn.tags.Name}"
        CreatedBy       = "terraform"
    }
}

resource "azurerm_network_interface" "bastion" {
    name = "pub_nic_bastion"
    location = "${var.azr_location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    ip_configuration {
        name = "pub_nic_bastion"
        subnet_id = "${element(azurerm_subnet.pub.*.id, 1)}"
        public_ip_address_id = "${azurerm_public_ip.bastion.id}"
        private_ip_address_allocation = "dynamic"
    }
}

resource "azurerm_virtual_machine" "bastion" {
    name = "ssh-bastion"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    location = "${azurerm_resource_group.rg.location}"
    network_interface_ids = [ "${azurerm_network_interface.bastion.id}" ]

    vm_size = "${var.azr_virtual_machine["vm_size"]}"

    storage_image_reference {
        publisher = "${var.azr_virtual_machine["storage_image_reference_publisher"]}"
        offer = "${var.azr_virtual_machine["storage_image_reference_offer"]}"
        sku = "${var.azr_virtual_machine["storage_image_reference_sku"]}"
        version = "${var.azr_virtual_machine["storage_image_reference_version"]}"
    }

    storage_os_disk {
        name = "bastion"
        vhd_uri = "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.vhds.name}/bastion.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "ssh-bastion"
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
        Name = "ssh-bastion"
        VirtualNetwork = "${azurerm_virtual_network.vn.tags.Name}"
        CreatedBy = "terraform"
    }
}

