resource "google_compute_firewall" "swarm" {
    name            = "docker-swarm"
    network         = "${var.google_compute_network["name"]}"
    source_ranges   = [ "0.0.0.0/0" ]

    allow {
        protocol    = "tcp"
        ports       = [ "22", "80", "443", "8080", "2377", "4789", "7946" ]
    }

    allow {
        protocol    = "udp"
        ports       = [ "4789", "7946" ]
    }
}

resource "google_compute_address" "mgr" {
    count = "${var.google_compute_instance_swarm_mgr["count"]}"

    name = "${var.google_compute_instance_swarm_mgr["name"]}-${count.index}"
}

resource "google_compute_instance" "mgr" {
    count = "${var.google_compute_instance_swarm_mgr["count"]}"

    name            = "swarm-mgr-${count.index}"
    machine_type    = "${var.google_compute_instance_swarm_mgr["machine_type"]}"
    zone            = "${element(var.google_compute_subnetwork["zone"], count.index)}"

    tags            = [ "terraform", "swarm", "mgr" ]

    boot_disk {
        initialize_params {
            image   = "${var.google_compute_instance_swarm_mgr["disk_image"]}"
        }
    }

    network_interface {
        subnetwork  = "${element(var.google_compute_subnetwork["name"], count.index)}"

        access_config {
            nat_ip  = "${element(google_compute_address.mgr.*.address, count.index)}"
        }
    }

    metadata {
        ssh-keys    = "ubuntu:${file("~/.ssh/gce.pub")}"
    }

    metadata {
        Name        = "${var.google_compute_instance_swarm_mgr["name"]}-${count.index}"
        VN          = "${var.google_compute_network["name"]}"
        CreatedBy   = "terraform"
    }
}

resource "google_compute_address" "wkr" {
    count = "${var.google_compute_instance_swarm_wkr["count"]}"

    name = "${var.google_compute_instance_swarm_wkr["name"]}-${count.index}"
}

resource "google_compute_instance" "wkr" {
    count = "${var.google_compute_instance_swarm_wkr["count"]}"

    name            = "swarm-wkr-${count.index}"
    machine_type    = "${var.google_compute_instance_swarm_wkr["machine_type"]}"
    zone            = "${element(var.google_compute_subnetwork["zone"], count.index)}"

    tags            = [ "terraform", "swarm", "wkr" ]

    boot_disk {
        initialize_params {
            image   = "${var.google_compute_instance_swarm_wkr["disk_image"]}"
        }
    }

    network_interface {
        subnetwork  = "${element(var.google_compute_subnetwork["name"], count.index)}"

        access_config {
            nat_ip  = "${element(google_compute_address.wkr.*.address, count.index)}"
        }
    }

    metadata {
        ssh-keys    = "ubuntu:${file("~/.ssh/gce.pub")}"
    }

    metadata {
        Name        = "${var.google_compute_instance_swarm_wkr["name"]}-${count.index}"
        VN          = "${var.google_compute_network["name"]}"
        CreatedBy   = "terraform"
    }
}

