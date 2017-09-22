output "vpc_id" {
    value = "${aws_vpc.vpc.id}"
}

output "vpc_name" {
    value = "${aws_vpc.vpc.tags["Name"]}"
}

output "pub_subnet_cidr_blocks" {
    value = "${aws_subnet.pub.*.cidr_block}"
}

output "pub_subnet_ids" {
    value = "${aws_subnet.pub.*.id}"
}

output "internal_security_group_id" {
    value = "${aws_security_group.internal.id}"
}

