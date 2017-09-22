module "amazon-vn" {
    source = "./amazon/virtual-network"

    aws_region      = "${var.aws_region}"
    aws_vpc         = "${var.aws_vpc}"
    aws_subnet      = "${var.aws_subnet}"
    aws_instance    = "${var.aws_instance}"
}

module "azure-vn" {
    source = "./azure/virtual-network"

    azr_location        = "${var.azr_location}"
    azr_vn              = "${var.azr_vn}"
    azr_subnets         = "${var.azr_subnets}"
    azr_storage_account = "${var.azr_storage_account}"
    azr_virtual_machine = "${var.azr_virtual_machine}"
}

module "google-vn" {
    source = "./google/virtual-network"

    gce_region      = "${var.gce_region}"
    gce_network     = "${var.gce_network}"
    gce_subnets     = "${var.gce_subnets}"
    gce_instance    = "${var.gce_instance}"
}

module "amazon-swarm" {
    source = "./amazon/swarm-stack"

    aws_vpc = {
        id      = "${module.amazon-vn.vpc_id}"
        name    = "${module.amazon-vn.vpc_name}"
    }

    aws_subnet = {
        cidr_blocks = "${module.amazon-vn.pub_subnet_cidr_blocks}"
        ids         = "${module.amazon-vn.pub_subnet_ids}"
    }

    aws_security_group = {
        internal    = "${module.amazon-vn.internal_security_group_id}"
    }

    aws_swarm_mgr_instance = {
        count           = "${var.aws_swarm_mgr_instance["count"]}"
        instance_type   = "${var.aws_swarm_mgr_instance["instance_type"]}"
        ami             = "${var.aws_swarm_mgr_instance["ami"]}"
        key_name        = "${var.aws_swarm_mgr_instance["key_name"]}"
        name            = "${var.aws_swarm_mgr_instance["name"]}"
    }

    aws_swarm_wkr_instance = {
        count           = "${var.aws_swarm_wkr_instance["count"]}"
        instance_type   = "${var.aws_swarm_wkr_instance["instance_type"]}"
        ami             = "${var.aws_swarm_wkr_instance["ami"]}"
        key_name        = "${var.aws_swarm_wkr_instance["key_name"]}"
        name            = "${var.aws_swarm_wkr_instance["name"]}"
    }
}

module "azure-swarm" {
    source = "./azure/swarm-stack"

    azurerm_resource_group = {
       name     = "${module.azure-vn.resource_group_name}"
       location = "${module.azure-vn.resource_group_location}"
    }

    azurerm_virtual_network = {
        name    = "${module.azure-vn.virtual_network_name}"
    }

    azurerm_subnet = {
        ids     = "${module.azure-vn.pub_subnet_ids}"
    }

    azurerm_storage_account = {
        primary_blob_endpoint = "${module.azure-vn.storage_account_primary_blob_endpoint}"
    }

    azurerm_storage_container = {
        name = "${module.azure-vn.storage_container_name}"
    }

    azurerm_swarm_mgr_virtual_machine = {
        count   = "${var.azurerm_swarm_mgr_virtual_machine["count"]}"
        vm_size = "${var.azurerm_swarm_mgr_virtual_machine["vm_size"]}"
        name    = "${var.azurerm_swarm_mgr_virtual_machine["name"]}"

        storage_image_reference_publisher   = "${var.azurerm_swarm_mgr_virtual_machine["storage_image_reference_publisher"]}"
        storage_image_reference_offer       = "${var.azurerm_swarm_mgr_virtual_machine["storage_image_reference_offer"]}"
        storage_image_reference_sku         = "${var.azurerm_swarm_mgr_virtual_machine["storage_image_reference_sku"]}"
        storage_image_reference_version     = "${var.azurerm_swarm_mgr_virtual_machine["storage_image_reference_version"]}"
    }

    azurerm_swarm_wkr_virtual_machine = {
        count   = "${var.azurerm_swarm_wkr_virtual_machine["count"]}"
        vm_size = "${var.azurerm_swarm_wkr_virtual_machine["vm_size"]}"
        name    = "${var.azurerm_swarm_wkr_virtual_machine["name"]}"

        storage_image_reference_publisher   = "${var.azurerm_swarm_wkr_virtual_machine["storage_image_reference_publisher"]}"
        storage_image_reference_offer       = "${var.azurerm_swarm_wkr_virtual_machine["storage_image_reference_offer"]}"
        storage_image_reference_sku         = "${var.azurerm_swarm_wkr_virtual_machine["storage_image_reference_sku"]}"
        storage_image_reference_version     = "${var.azurerm_swarm_wkr_virtual_machine["storage_image_reference_version"]}"
    }
}

module "google-swarm" {
    source = "./google/swarm-stack"

    google_compute_network = {
        name = "${module.google-vn.network_name}"
    }

    google_compute_subnetwork = {
        zone = "${var.gce_subnets["pub_zones"]}"
        name = "${module.google-vn.pub_subnetwork_name}"
    }

    google_compute_instance_swarm_mgr = {
        count           = "${var.google_compute_instance_swarm_mgr["count"]}"
        machine_type    = "${var.google_compute_instance_swarm_mgr["machine_type"]}"
        disk_image      = "${var.google_compute_instance_swarm_mgr["disk_image"]}"
        name            = "${var.google_compute_instance_swarm_mgr["name"]}"
    }

    google_compute_instance_swarm_wkr = {
        count           = "${var.google_compute_instance_swarm_wkr["count"]}"
        machine_type    = "${var.google_compute_instance_swarm_wkr["machine_type"]}"
        disk_image      = "${var.google_compute_instance_swarm_wkr["disk_image"]}"
        name            = "${var.google_compute_instance_swarm_wkr["name"]}"
    }
}

data "template_file" "inventory" {
    template = "${file("templates/inventory.tpl")}"

    vars {
        aws_swarm_managers  = "${join("\n", formatlist("%15s ansible_ssh_user=ubuntu ansible_ssh_private_key_file=~/.ssh/terraform.pem", module.amazon-swarm.aws_swarm_mgr_public_ips))}"
        aws_swarm_workers   = "${join("\n", formatlist("%15s ansible_ssh_user=ubuntu ansible_ssh_private_key_file=~/.ssh/terraform.pem", module.amazon-swarm.aws_swarm_wkr_public_ips))}"

        azr_swarm_managers  = "${join("\n", formatlist("%15s ansible_ssh_user=ubuntu ansible_ssh_private_key_file=~/.ssh/azr", module.azure-swarm.azurerm_swarm_mgr_public_ips))}"
        azr_swarm_workers   = "${join("\n", formatlist("%15s ansible_ssh_user=ubuntu ansible_ssh_private_key_file=~/.ssh/azr", module.azure-swarm.azurerm_swarm_wkr_public_ips))}"

        gce_swarm_managers  = "${join("\n", formatlist("%15s ansible_ssh_user=ubuntu ansible_ssh_private_key_file=~/.ssh/gce", module.google-swarm.swarm_mgr_public_ips))}"
        gce_swarm_workers   = "${join("\n", formatlist("%15s ansible_ssh_user=ubuntu ansible_ssh_private_key_file=~/.ssh/gce", module.google-swarm.swarm_wkr_public_ips))}"
    }

    depends_on = [
        "module.amazon-swarm",
        "module.azure-swarm",
        "module.google-swarm"
    ]
}

resource "local_file" "inventory" {
    content     = "${data.template_file.inventory.rendered}"
    filename    = "ansible/hosts"
}

