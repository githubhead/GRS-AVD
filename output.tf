output "location" {
  description = "The Azure region"
  value       = azurerm_resource_group.avd_rg.location
}

output "dnsservers" {
  description = "Custom DNS configuration"
  value       = azurerm_virtual_network.avd_vnet.dns_servers
}

output "vnet_address_space" {
  description = "Address range for deployment vnet"
  value       = azurerm_virtual_network.avd_vnet.address_space
}

output "subnet_address_prefix" {
    description = "Subnet where AVD instances will be created"
    value = azurerm_subnet.avd_subnet.address_prefixes
}

output "session_host_count" {
    description = "Number of host VMs created"
    value = var.avd_prod_session_host_count
}