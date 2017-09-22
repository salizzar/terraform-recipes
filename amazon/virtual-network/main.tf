provider "aws" {
    region = "${var.aws_region}"
}

resource "aws_vpc" "vpc" {
    cidr_block  = "${var.aws_vpc["cidr_block"]}"

    enable_dns_support = "${var.aws_vpc["enable_dns_support"]}"
    enable_dns_hostnames = "${var.aws_vpc["enable_dns_hostnames"]}"

    tags {
        Name = "${var.aws_vpc["name"]}"
        CreatedBy = "terraform"
    }
}

resource "aws_internet_gateway" "default" {
    vpc_id  = "${aws_vpc.vpc.id}"

    tags {
        Name = "${var.aws_vpc["name"]}_igw"
        VirtualNetwork = "${aws_vpc.vpc.tags.Name}"
        CreatedBy = "terraform"
    }
}

resource "aws_eip" "eip_nat" {
    vpc = true

    depends_on = [ "aws_internet_gateway.default" ]
}

resource "aws_nat_gateway" "default" {
    allocation_id   = "${aws_eip.eip_nat.id}"
    subnet_id       = "${aws_subnet.pub.1.id}"

    depends_on      = [ "aws_internet_gateway.default", "aws_subnet.pub" ]
}

# public subnets

resource "aws_route_table" "pub" {
    vpc_id  = "${aws_vpc.vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id  = "${aws_internet_gateway.default.id}"
    }

    tags {
        Name = "${var.aws_vpc["name"]}_rt_pub"
        VirtualNetwork = "${aws_vpc.vpc.tags.Name}"
        CreatedBy = "terraform"
    }
}

resource "aws_subnet" "pub" {
    vpc_id  = "${aws_vpc.vpc.id}"

    count = "${length(var.aws_subnet["pub_cidr_blocks"])}"

    cidr_block              = "${element(var.aws_subnet["pub_cidr_blocks"], count.index)}"
    availability_zone       = "${element(var.aws_subnet["pub_availability_zones"], count.index)}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "${element(var.aws_subnet["pub_availability_zones"], count.index)}_pub"
        VirtualNetwork = "${aws_vpc.vpc.tags.Name}"
        CreatedBy = "terraform"
    }
}

resource "aws_route_table_association" "pub" {
    count = "${length(var.aws_subnet["pub_cidr_blocks"])}"

    subnet_id       = "${element(aws_subnet.pub.*.id, count.index)}"
    route_table_id  = "${aws_route_table.pub.id}"
}

# private subnets

resource "aws_route_table" "prv" {
    vpc_id  = "${aws_vpc.vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id  = "${aws_nat_gateway.default.id}"
    }

    tags {
        Name = "${var.aws_vpc["name"]}_rt_pub"
        VirtualNetwork = "${aws_vpc.vpc.tags.Name}"
        CreatedBy = "terraform"
    }
}

resource "aws_subnet" "prv" {
    vpc_id  = "${aws_vpc.vpc.id}"

    count = "${length(var.aws_subnet["prv_cidr_blocks"])}"

    cidr_block              = "${element(var.aws_subnet["prv_cidr_blocks"], count.index)}"
    availability_zone       = "${element(var.aws_subnet["prv_availability_zones"], count.index)}"

    tags {
        Name = "${element(var.aws_subnet["prv_availability_zones"], count.index)}_prv"
        VirtualNetwork = "${aws_vpc.vpc.tags.Name}"
        CreatedBy = "terraform"
    }
}

resource "aws_route_table_association" "prv" {
    count = "${length(var.aws_subnet["prv_cidr_blocks"])}"

    subnet_id       = "${element(aws_subnet.prv.*.id, count.index)}"
    route_table_id  = "${aws_route_table.prv.id}"
}

# bastion security group

resource "aws_security_group" "bastion" {
    name = "Bastion"
    description = "Allows access from world to bastion"
    vpc_id = "${aws_vpc.vpc.id}"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    tags {
        Name = "Bastion"
        VirtualNetwork = "${aws_vpc.vpc.tags.Name}"
        CreatedBy = "terraform"
    }
}

# internal security group

resource "aws_security_group" "internal" {
    name = "Internal SSH"
    description = "Allows access from bastion to internal servers"
    vpc_id = "${aws_vpc.vpc.id}"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [ "${aws_instance.bastion.private_ip}/32" ]
    }

    tags {
        Name = "Internal from bastion"
        VirtualNetwork = "${aws_vpc.vpc.tags.Name}"
        CreatedBy = "terraform"
    }

    depends_on = [ "aws_instance.bastion" ]
}

# bastion public ip

resource "aws_eip" "bastion" {
    vpc         = true
    instance    = "${aws_instance.bastion.id}"
}

# bastion server

resource "aws_instance" "bastion" {
    instance_type   = "${var.aws_instance["instance_type"]}"
    ami             = "${var.aws_instance["ami"]}"
    key_name        = "${var.aws_instance["key_name"]}"

    subnet_id              = "${aws_subnet.pub.1.id}"
    vpc_security_group_ids = [ "${aws_security_group.bastion.id}" ]

    tags {
        Name = "ssh-bastion"
        VirtualNetwork = "${aws_vpc.vpc.tags.Name}"
        CreatedBy = "terraform"
    }

    depends_on = [ "aws_security_group.bastion", "aws_subnet.pub" ]
}

