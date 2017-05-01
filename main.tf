module "amazon" {
    source = "./amazon"

    aws_region      = "${var.aws_region}"
    aws_vpc         = "${var.aws_vpc}"
    aws_subnet      = "${var.aws_subnet}"
    aws_instance    = "${var.aws_instance}"
}

module "azure" {
    source = "./azure"

    azr_location        = "${var.azr_location}"
    azr_vn              = "${var.azr_vn}"
    azr_subnets         = "${var.azr_subnets}"
    azr_storage_account = "${var.azr_storage_account}"
    azr_virtual_machine = "${var.azr_virtual_machine}"
}

module "google" {
    source = "./google"

    gce_region      = "${var.gce_region}"
    gce_network     = "${var.gce_network}"
    gce_subnets     = "${var.gce_subnets}"
    gce_instance    = "${var.gce_instance}"
}

