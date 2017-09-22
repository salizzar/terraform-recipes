gce_region = "us-central1"

gce_network = {
	name = "terraform-lab"
	description = "Terraform GCE network"
}

gce_subnets = {
	pub_cidr_blocks = [ "192.168.0.0/24", "192.168.2.0/24", "192.168.4.0/24" ]
	prv_cidr_blocks = [ "192.168.1.0/24", "192.168.3.0/24", "192.168.5.0/24" ]

	pub_zones = [ "us-central1-b", "us-central1-a", "us-central1-c" ]
	prv_zones = [ "us-central1-b", "us-central1-a", "us-central1-c" ]
}

gce_instance = {
	machine_type = "f1-micro"
	disk_image = "ubuntu-1604-lts"
}

