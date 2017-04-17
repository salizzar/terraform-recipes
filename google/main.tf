provider "google" {
    credentials = "${file("/root/terraform.json")}"
}

resource "google_compute_network" "vn" {
    name        = "${var.gce_network["name"]}"
    description = "${var.gce_network["description"]}"
}

# public subnets

resource "google_compute_subnetwork" "pub" {
    count           = "${length(var.gce_subnets["pub_cidr_blocks"])}"

    name            = "pub-${count.index + 1}-${var.gce_region}"
    network         = "${google_compute_network.vn.name}"
    ip_cidr_range   = "${element(var.gce_subnets["pub_cidr_blocks"], count.index)}"
}

# private subnets

resource "google_compute_subnetwork" "prv" {
    count           = "${length(var.gce_subnets["prv_cidr_blocks"])}"

    name            = "prv-${count.index + 1}-${var.gce_region}"
    network         = "${google_compute_network.vn.name}"
    ip_cidr_range   = "${element(var.gce_subnets["prv_cidr_blocks"], count.index)}"
}

# bastion firewall

resource "google_compute_firewall" "bastion" {
    name            = "bastionfw"
    network         = "${google_compute_network.vn.name}"
    source_ranges   = [ "0.0.0.0/0" ]

    allow {
        protocol    = "icmp"
    }

    allow {
        protocol    = "tcp"
        ports       = [ "22" ]
    }
}

# internal firewall

resource "google_compute_firewall" "internal" {
    name            = "internalfw"
    network         = "${google_compute_network.vn.name}"
    source_ranges   = [ "${google_compute_instance.bastion.network_interface.0.address}/32" ]

    allow {
        protocol    = "icmp"
    }

    allow {
        protocol    = "tcp"
        ports       = [ "22" ]
    }
}

# bastion server

resource "google_compute_address" "bastion" {
  name = "bastion-ip"
}

resource "google_compute_instance" "bastion" {
    name            = "bastion"
    machine_type    = "${var.gce_instance["machine_type"]}"
    zone            = "${element(var.gce_subnets["pub_zones"], 1)}"
    can_ip_forward  = true
    tags            = [ "terraform", "ssh" ]

    disk {
        image       = "${var.gce_instance["disk_image"]}"
    }

    network_interface {
        subnetwork  = "${element(google_compute_subnetwork.pub.*.name, 1)}"

        access_config {
            nat_ip  = "${google_compute_address.bastion.address}"
        }
    }

    metadata {
        ssh-keys    = "ubuntu:${file("/root/.ssh/gce.pub")}"
    }

    metadata {
        Name        = "SSH Bastion"
        VN          = "${google_compute_network.vn.name}"
        CreatedBy   = "terraform"
    }
}

# instances to test internal subnets

resource "google_compute_instance" "test" {
    count = "${length(var.gce_subnets["prv_cidr_blocks"])}"

    name            = "test-${count.index}"
    machine_type    = "${var.gce_instance["machine_type"]}"
    zone            = "${element(var.gce_subnets["prv_zones"], count.index)}"

    tags            = [ "terraform", "test" ]

    disk {
        image       = "${var.gce_instance["disk_image"]}"
    }

    network_interface {
        subnetwork  = "${element(google_compute_subnetwork.prv.*.name, count.index)}"
    }

    metadata {
        ssh-keys    = "ubuntu:${file("/root/.ssh/gce.pub")}"
    }

    metadata {
        Name        = "Private Subnet Instance ${count.index}"
        VN          = "${google_compute_network.vn.name}"
        CreatedBy   = "terraform"
    }
}


