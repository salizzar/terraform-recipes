output "aws_swarm_mgr_public_ips" {
    value = "${aws_instance.mgr.*.public_ip}"
}

output "aws_swarm_wkr_public_ips" {
    value = "${aws_instance.wkr.*.public_ip}"
}

