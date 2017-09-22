output "network_name" {
    value = "${google_compute_network.vn.name}"
}

output "pub_subnetwork_name" {
    value = "${google_compute_subnetwork.pub.*.name}"
}

