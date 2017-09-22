output "swarm_mgr_public_ips" {
    value = "${google_compute_address.mgr.*.address}"
}

output "swarm_wkr_public_ips" {
    value = "${google_compute_address.wkr.*.address}"
}

