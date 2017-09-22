provider "google" {
}

resource "google_compute_network" "vn" {
    name        = "${var.gce_network["name"]}"
    description = "${var.gce_network["description"]}"
}

resource "google_compute_route" "rt" {
    network     = "${google_compute_network.vn.name}"
    name        = "noip-internet-rt"
    dest_range  = "0.0.0.0/0"
    priority    = 100

    tags        = [ "noip" ]

    next_hop_instance = "${google_compute_instance.bastion.name}"
    next_hop_instance_zone = "${google_compute_instance.bastion.zone}"
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

resource "google_compute_firewall" "bastion-ssh" {
    name            = "bastionfw-ssh"
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

resource "google_compute_firewall" "internal-ssh" {
    name            = "internalfw-ssh"
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
    name            = "ssh-bastion"
    machine_type    = "${var.gce_instance["machine_type"]}"
    zone            = "${element(var.gce_subnets["pub_zones"], 1)}"
    can_ip_forward  = true
    tags            = [ "terraform", "ssh" ]

    boot_disk {
        initialize_params {
            image   = "${var.gce_instance["disk_image"]}"
        }
    }

    network_interface {
        subnetwork  = "${element(google_compute_subnetwork.pub.*.name, 1)}"

        access_config {
            nat_ip  = "${google_compute_address.bastion.address}"
        }
    }

    metadata {
        ssh-keys    = "ubuntu:${file("~/.ssh/gce.pub")}"
    }

    metadata {
        Name        = "SSH Bastion"
        VN          = "${google_compute_network.vn.name}"
        CreatedBy   = "terraform"
    }
}

