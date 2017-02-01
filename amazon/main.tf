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
        VPC = "${aws_vpc.vpc.tags.Name}"
        CreatedBy = "terraform"
    }
}

resource "aws_eip" "eip_nat" {
    vpc = true

    depends_on = [ "aws_internet_gateway.default" ]
}

resource "aws_nat_gateway" "default" {
    allocation_id   = "${aws_eip.eip_nat.id}"
    subnet_id       = "${aws_subnet.pub_1.id}"

    depends_on      = [ "aws_internet_gateway.default" ]
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
        VPC = "${aws_vpc.vpc.tags.Name}"
        CreatedBy = "terraform"
    }
}

resource "aws_subnet" "pub_1" {
    vpc_id  = "${aws_vpc.vpc.id}"

    cidr_block              = "${var.aws_subnet["pub_1_cidr_block"]}"
    availability_zone       = "${var.aws_subnet["pub_1_availability_zone"]}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "${var.aws_subnet["pub_1_availability_zone"]}_pub"
        VPC = "${aws_vpc.vpc.tags.Name}"
        CreatedBy = "terraform"
    }
}

resource "aws_subnet" "pub_2" {
    vpc_id  = "${aws_vpc.vpc.id}"

    cidr_block              = "${var.aws_subnet["pub_2_cidr_block"]}"
    availability_zone       = "${var.aws_subnet["pub_2_availability_zone"]}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "${var.aws_subnet["pub_2_availability_zone"]}_pub"
        VPC = "${aws_vpc.vpc.tags.Name}"
        CreatedBy = "terraform"
    }
}

resource "aws_subnet" "pub_3" {
    vpc_id  = "${aws_vpc.vpc.id}"

    cidr_block              = "${var.aws_subnet["pub_3_cidr_block"]}"
    availability_zone       = "${var.aws_subnet["pub_3_availability_zone"]}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "${var.aws_subnet["pub_3_availability_zone"]}_pub"
        VPC = "${aws_vpc.vpc.tags.Name}"
        CreatedBy = "terraform"
    }
}

resource "aws_route_table_association" "pub_1" {
    subnet_id       = "${aws_subnet.pub_1.id}"
    route_table_id  = "${aws_route_table.pub.id}"
}

resource "aws_route_table_association" "pub_2" {
    subnet_id       = "${aws_subnet.pub_2.id}"
    route_table_id  = "${aws_route_table.pub.id}"
}

resource "aws_route_table_association" "pub_3" {
    subnet_id       = "${aws_subnet.pub_3.id}"
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
        VPC = "${aws_vpc.vpc.tags.Name}"
        CreatedBy = "terraform"
    }
}

resource "aws_subnet" "prv_1" {
    vpc_id  = "${aws_vpc.vpc.id}"

    cidr_block          = "${var.aws_subnet["prv_1_cidr_block"]}"
    availability_zone   = "${var.aws_subnet["prv_1_availability_zone"]}"

    tags {
        Name = "${var.aws_subnet["prv_1_availability_zone"]}_prv"
        VPC = "${aws_vpc.vpc.tags.Name}"
        CreatedBy = "terraform"
    }
}

resource "aws_subnet" "prv_2" {
    vpc_id  = "${aws_vpc.vpc.id}"

    cidr_block          = "${var.aws_subnet["prv_2_cidr_block"]}"
    availability_zone   = "${var.aws_subnet["prv_2_availability_zone"]}"

    tags {
        Name = "${var.aws_subnet["prv_2_availability_zone"]}_prv"
        VPC = "${aws_vpc.vpc.tags.Name}"
        CreatedBy = "terraform"
    }
}

resource "aws_subnet" "prv_3" {
    vpc_id  = "${aws_vpc.vpc.id}"

    cidr_block          = "${var.aws_subnet["prv_3_cidr_block"]}"
    availability_zone   = "${var.aws_subnet["prv_3_availability_zone"]}"

    tags {
        Name = "${var.aws_subnet["prv_3_availability_zone"]}_prv"
        VPC = "${aws_vpc.vpc.tags.Name}"
        CreatedBy = "terraform"
    }
}

resource "aws_route_table_association" "prv_1" {
    subnet_id       = "${aws_subnet.prv_1.id}"
    route_table_id  = "${aws_route_table.prv.id}"
}

resource "aws_route_table_association" "prv_2" {
    subnet_id       = "${aws_subnet.prv_2.id}"
    route_table_id  = "${aws_route_table.prv.id}"
}

resource "aws_route_table_association" "prv_3" {
    subnet_id       = "${aws_subnet.prv_3.id}"
    route_table_id  = "${aws_route_table.prv.id}"
}

# bastion security group

resource "aws_security_group" "bastion" {
    name = "VPC Bastion"
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
        VPC = "${aws_vpc.vpc.tags.Name}"
        CreatedBy = "terraform"
    }
}

# internal security group

resource "aws_security_group" "internal" {
    name = "VPC Internal SSH"
    description = "Allows access from bastion to internal servers"
    vpc_id = "${aws_vpc.vpc.id}"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [ "${aws_instance.bastion.private_ip}/32" ]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    tags {
        Name = "Internal from bastion"
        VPC = "${aws_vpc.vpc.tags.Name}"
        CreatedBy = "terraform"
    }

    depends_on = [ "aws_instance.bastion" ]
}

# recover ubuntu image

data "aws_ami" "default" {
    most_recent = true

    filter {
        name = "name"
        values = [ "amzn-ami-hvm-*-gp2" ]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["amazon"]
}

# bastion server

resource "aws_instance" "bastion" {
    ami = "${data.aws_ami.default.id}"

    instance_type   = "t2.nano"
    key_name        = "terraform"

    subnet_id              = "${aws_subnet.pub_2.id}"
    vpc_security_group_ids = [ "${aws_security_group.bastion.id}" ]

    tags {
        Name = "SSH Bastion"
        VPC = "${aws_vpc.vpc.tags.Name}"
        CreatedBy = "terraform"
    }

    depends_on = [ "aws_security_group.bastion" ]
}

