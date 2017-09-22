# security group

resource "azurerm_network_security_group" "sg" {
    name = "Docker-Swarm"
    resource_group_name = "${var.azurerm_resource_group["name"]}"
    location = "${var.azurerm_resource_group["location"]}"
}

# ssh ingress

resource "azurerm_network_security_rule" "swarm-inbound-ssh" {
    name = "swarm_inbound_ssh"
    resource_group_name = "${var.azurerm_resource_group["name"]}"
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

# http ingress

resource "azurerm_network_security_rule" "swarm-inbound-http" {
    name = "swarm_inbound_http"
    resource_group_name = "${var.azurerm_resource_group["name"]}"
    network_security_group_name = "${azurerm_network_security_group.sg.name}"
    priority = 101
    direction = "Inbound"
    access = "Allow"
    protocol = "tcp"
    source_port_range = "80"
    destination_port_range = "80"
    source_address_prefix = "*"
    destination_address_prefix = "*"
}

# https ingress

resource "azurerm_network_security_rule" "swarm-inbound-https" {
    name = "swarm_inbound_https"
    resource_group_name = "${var.azurerm_resource_group["name"]}"
    network_security_group_name = "${azurerm_network_security_group.sg.name}"
    priority = 102
    direction = "Inbound"
    access = "Allow"
    protocol = "tcp"
    source_port_range = "443"
    destination_port_range = "443"
    source_address_prefix = "*"
    destination_address_prefix = "*"
}

# traefik ingress

resource "azurerm_network_security_rule" "swarm-inbound-traefik" {
    name = "swarm_inbound_traefik"
    resource_group_name = "${var.azurerm_resource_group["name"]}"
    network_security_group_name = "${azurerm_network_security_group.sg.name}"
    priority = 103
    direction = "Inbound"
    access = "Allow"
    protocol = "tcp"
    source_port_range = "8080"
    destination_port_range = "8080"
    source_address_prefix = "*"
    destination_address_prefix = "*"
}

# swarm 2377 tcp

resource "azurerm_network_security_rule" "swarm-inbound-swarm-2377" {
    name = "swarm_inbound_swarm_2377"
    resource_group_name = "${var.azurerm_resource_group["name"]}"
    network_security_group_name = "${azurerm_network_security_group.sg.name}"
    priority = 104
    direction = "Inbound"
    access = "Allow"
    protocol = "tcp"
    source_port_range = "2377"
    destination_port_range = "2377"
    source_address_prefix = "*"
    destination_address_prefix = "*"
}

# swarm 4789 tcp/udp

resource "azurerm_network_security_rule" "swarm-inbound-swarm-4789" {
    name = "swarm_inbound_swarm_4789"
    resource_group_name = "${var.azurerm_resource_group["name"]}"
    network_security_group_name = "${azurerm_network_security_group.sg.name}"
    priority = 105
    direction = "Inbound"
    access = "Allow"
    protocol = "*"
    source_port_range = "4789"
    destination_port_range = "4789"
    source_address_prefix = "*"
    destination_address_prefix = "*"
}

# swarm 7946 tcp/udp

resource "azurerm_network_security_rule" "swarm-inbound-swarm-7946" {
    name = "swarm_inbound_swarm_7946"
    resource_group_name = "${var.azurerm_resource_group["name"]}"
    network_security_group_name = "${azurerm_network_security_group.sg.name}"
    priority = 106
    direction = "Inbound"
    access = "Allow"
    protocol = "*"
    source_port_range = "7946"
    destination_port_range = "7946"
    source_address_prefix = "*"
    destination_address_prefix = "*"
}

# outbound traffic

resource "azurerm_network_security_rule" "swarm-outbound" {
    name = "swarm_outbound"
    resource_group_name = "${var.azurerm_resource_group["name"]}"
    network_security_group_name = "${azurerm_network_security_group.sg.name}"
    priority = 107
    direction = "Outbound"
    access = "Allow"
    protocol = "*"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "*"
    destination_address_prefix = "*"
}

