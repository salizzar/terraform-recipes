variable "google_compute_network" {
    type = "map"

    default = {
        name = ""
    }
}

variable "google_compute_subnetwork" {
    type = "map"

    default = {
        name = []
        zone = []
    }
}

variable "google_compute_instance_swarm_mgr" {
    type = "map"

    default = {
        count = 0
        machine_type = ""
        disk_image = ""
        name = ""
    }
}

variable "google_compute_instance_swarm_wkr" {
    type = "map"

    default = {
        count = 0
        machine_type = ""
        disk_image = ""
        name = ""
    }
}

