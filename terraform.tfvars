#
# amazon
#

aws_region = "us-east-1"

aws_vpc = {
        name = "terraform-lab"
        cidr_block = "10.0.0.0/16"
        enable_dns_support = "true"
        enable_dns_hostnames = "true"
}

aws_subnet = {
        pub_cidr_blocks = [ "10.0.0.0/24", "10.0.2.0/24", "10.0.4.0/24" ]
        prv_cidr_blocks = [ "10.0.1.0/24", "10.0.3.0/24", "10.0.5.0/24" ]

        pub_availability_zones = [ "us-east-1b", "us-east-1a", "us-east-1c" ]
        prv_availability_zones = [ "us-east-1b", "us-east-1a", "us-east-1c" ]
}

aws_instance = {
        instance_type = "t2.nano"
        ami = "ami-f4cc1de2"
        key_name = "terraform"
}

#
# azure
#

azr_location = "eastus2"

azr_vn = {
        name = "terraform-lab"
        address_space = "172.16.0.0/16"
}

azr_subnets = {
        pub_cidr_blocks = [ "172.16.0.0/24", "172.16.2.0/24", "172.16.4.0/24" ]
        prv_cidr_blocks = [ "172.16.1.0/24", "172.16.3.0/24", "172.16.5.0/24" ]
}

azr_storage_account = {
        name = "terraformlab"
        account_type = "Standard_LRS"
}

azr_virtual_machine = {
        vm_size = "Standard_A0"

        storage_image_reference_publisher = "Canonical"
        storage_image_reference_offer = "UbuntuServer"
        storage_image_reference_sku = "16.04-LTS"
        storage_image_reference_version = "latest"

        admin_username = "ubuntu"
        admin_password = "Ubuntu!@#$"
}

#
# google
#

gce_region = "us-central1"

gce_network = {
        name = "terraform-lab"
        description = "Terraform GCE network"
}

gce_subnets = {
        pub_cidr_blocks = [ "192.168.0.0/24", "192.168.2.0/24", "192.168.4.0/24" ]
        prv_cidr_blocks = [ "192.168.1.0/24", "192.168.3.0/24", "192.168.5.0/24" ]

        pub_zones = [ "us-central1-b", "us-central1-a", "us-central1-c" ]
        prv_zones = [ "us-central1-b", "us-central1-a", "us-central1-c" ]
}

gce_instance = {
        machine_type = "f1-micro"
        disk_image = "ubuntu-1604-lts"
}


#
# amazon swarm
#

aws_swarm_mgr_instance = {
        count = 3
        instance_type = "t2.small"
        ami = "ami-e13739f6"
        key_name = "terraform"
        name = "swarm-mgr"
}

aws_swarm_wkr_instance = {
        count = 3
        instance_type = "t2.small"
        ami = "ami-e13739f6"
        key_name = "terraform"
        name = "swarm-wkr"
}

#
# azure swarm
#

azurerm_swarm_mgr_virtual_machine = {
        count = 3
        vm_size = "Standard_A1"
        name = "swarm-mgr"

        storage_image_reference_publisher = "Canonical"
        storage_image_reference_offer = "UbuntuServer"
        storage_image_reference_sku = "16.04-LTS"
        storage_image_reference_version = "latest"
}

azurerm_swarm_wkr_virtual_machine = {
        count = 3
        vm_size = "Standard_A1"
        name = "swarm-wkr"

        storage_image_reference_publisher = "Canonical"
        storage_image_reference_offer = "UbuntuServer"
        storage_image_reference_sku = "16.04-LTS"
        storage_image_reference_version = "latest"
}

#
# google swarm
#

google_compute_instance_swarm_mgr = {
        count = 3
        machine_type = "n1-standard-1"
        disk_image = "ubuntu-1604-lts"
        name = "swarm-mgr"
}

google_compute_instance_swarm_wkr = {
        count = 3
        machine_type = "n1-standard-1"
        disk_image = "ubuntu-1604-lts"
        name = "swarm-wkr"
}

