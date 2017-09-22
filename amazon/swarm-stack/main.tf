resource "aws_security_group" "swarm" {
    name = "Docker-Swarm"
    vpc_id = "${var.aws_vpc["id"]}"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    # traefik panel
    ingress {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    # swarm
    ingress {
        from_port   = 2377
        to_port     = 2377
        protocol    = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    # swarm
    ingress {
        from_port   = 4789
        to_port     = 4789
        protocol    = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    # swarm
    ingress {
        from_port   = 4789
        to_port     = 4789
        protocol    = "udp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    # swarm
    ingress {
        from_port   = 7946
        to_port     = 7946
        protocol    = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    # swarm
    ingress {
        from_port   = 7946
        to_port     = 7946
        protocol    = "udp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    tags {
        Name = "Docker Swarm"
        CreatedBy = "terraform"
    }
}

resource "aws_instance" "mgr" {
    count = "${var.aws_swarm_mgr_instance["count"]}"

    instance_type   = "${var.aws_swarm_mgr_instance["instance_type"]}"
    ami             = "${var.aws_swarm_mgr_instance["ami"]}"
    key_name        = "${var.aws_swarm_mgr_instance["key_name"]}"

    subnet_id              = "${element(var.aws_subnet["ids"], count.index)}"

    vpc_security_group_ids = [
        "${var.aws_security_group["internal"]}",
        "${aws_security_group.swarm.id}"
    ]

    tags {
        Name = "${var.aws_swarm_mgr_instance["name"]}-${count.index}"
        VirtualNetwork = "${var.aws_vpc["name"]}"
        CreatedBy = "terraform"
    }
}

resource "aws_instance" "wkr" {
    count = "${var.aws_swarm_wkr_instance["count"]}"

    instance_type   = "${var.aws_swarm_wkr_instance["instance_type"]}"
    ami             = "${var.aws_swarm_wkr_instance["ami"]}"
    key_name        = "${var.aws_swarm_wkr_instance["key_name"]}"

    subnet_id              = "${element(var.aws_subnet["ids"], count.index)}"

    vpc_security_group_ids = [
        "${var.aws_security_group["internal"]}",
        "${aws_security_group.swarm.id}"
    ]

    tags {
        Name = "${var.aws_swarm_wkr_instance["name"]}-${count.index}"
        VirtualNetwork = "${var.aws_vpc["name"]}"
        CreatedBy = "terraform"
    }
}

