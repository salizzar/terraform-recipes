azr_location = "eastus2"

azr_vn = {
	name = "terraform-lab"
	address_space = "172.16.0.0/16"
}

azr_subnets = {
	pub_cidr_blocks = [ "172.16.0.0/24", "172.16.2.0/24", "172.16.4.0/24" ]
	prv_cidr_blocks = [ "172.16.1.0/24", "172.16.3.0/24", "172.16.5.0/24" ]
}

azr_storage_account = {
	name = "terraform-lab"
	account_type = "Standard_LRS"
}

azr_virtual_machine = {
	vm_size = "Standard_A0"

	storage_image_reference_publisher = "Canonical"
	storage_image_reference_offer = "UbuntuServer"
	storage_image_reference_sku = "16.04-LTS"
	storage_image_reference_version = "latest"

	admin_username = "ubuntu"
	admin_password = "Ubuntu!@#$"
}

