output "resource_group_name" {
    value = "${azurerm_resource_group.rg.name}"
}

output "resource_group_location" {
    value = "${azurerm_resource_group.rg.location}"
}

output "virtual_network_name" {
    value = "${azurerm_virtual_network.vn.name}"
}

output "pub_subnet_ids" {
    value = "${azurerm_subnet.pub.*.id}"
}

output "storage_account_primary_blob_endpoint" {
    value = "${azurerm_storage_account.storage.primary_blob_endpoint}"
}

output "storage_container_name" {
    value = "${azurerm_storage_container.vhds.name}"
}

