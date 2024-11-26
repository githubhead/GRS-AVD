output "vnet_spoke_name_out" {
    description = "vnet spoke name out var"
    value = azurerm_virtual_network.avd_spoke_vnet.name
}

output "avd_subnet_rgname_out" {
    description = "Resource group name for avd subnet"
    value = azurerm_resource_group.avd_net_rg.name
}

output "avd_subnet_id_out" {
    description = "AVD service subnet"
    value       = azurerm_subnet.avd_subnet.id
}

output "sa_pe_blob_private_dns_zone_id_out" {
    description = "Private DNS zone id for blob storage accounts"
    value       = azurerm_private_dns_zone.pep_blob_private_dns_zone.id
}

output "sa_pe_blob_private_dns_zone_name_out" {
    description = "Private DNS zone name for blob storage accounts"
    value = azurerm_private_dns_zone.pep_blob_private_dns_zone.name
}

output "sa_pe_file_private_dns_zone_id_out" {
    description = "Private DNS zone id for file storage accounts"
    value       = azurerm_private_dns_zone.pep_file_private_dns_zone.id
}

output "sa_pe_file_private_dns_zone_name_out" {
    description = "Private DNS zone name for file storage accounts"
    value = azurerm_private_dns_zone.pep_file_private_dns_zone.name
}