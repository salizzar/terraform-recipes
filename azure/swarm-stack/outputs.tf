output "azurerm_swarm_mgr_public_ips" {
    value = "${azurerm_public_ip.mgr.*.ip_address}"
}

output "azurerm_swarm_wkr_public_ips" {
    value = "${azurerm_public_ip.wkr.*.ip_address}"
}

