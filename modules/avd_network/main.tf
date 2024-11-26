#create resource group to aggregate all avd network components
resource "azurerm_resource_group" "avd_net_rg" {
    name     = "${var.env}-${var.avd_net_rg}"
    location = var.location
}

# create avd virtual network
resource "azurerm_virtual_network" "avd_spoke_vnet" {
    name                = "${var.env}-${var.vnet_spoke_name}"
    address_space       = var.vnet_spoke_address_space
    #dns_servers         = var.dns_servers
    resource_group_name = azurerm_resource_group.avd_net_rg.name
    location            = azurerm_resource_group.avd_net_rg.location
    depends_on          = [ azurerm_resource_group.avd_net_rg ]
}

resource "azurerm_subnet" "avd_subnet" {
    name                 = "${var.env}-${var.avd_subnet_name}"
    resource_group_name  = azurerm_resource_group.avd_net_rg.name
    virtual_network_name = azurerm_virtual_network.avd_spoke_vnet.name
    address_prefixes     = var.avd_subnet_address_prefix
    service_endpoints    = ["Microsoft.Storage"]
    #private_endpoint_network_policies = Enabled
    depends_on           = [ azurerm_resource_group.avd_net_rg ]
}

resource "azurerm_subnet" "ad_subnet" {
    name                 = "${var.env}-${var.ad_subnet_name}"
    resource_group_name  = azurerm_resource_group.avd_net_rg.name
    virtual_network_name = azurerm_virtual_network.avd_spoke_vnet.name
    address_prefixes     = var.ad_subnet_address_prefix
    service_endpoints    = ["Microsoft.Storage"]
    #private_endpoint_network_policies = Enabled
    depends_on           = [ azurerm_resource_group.avd_net_rg ]
}

resource "azurerm_network_security_group" "avd_nsg" {
    name                  = "${var.env}-avd-NSG"
    location              = azurerm_resource_group.avd_net_rg.location
    resource_group_name   = azurerm_resource_group.avd_net_rg.name
    security_rule {
        name                       = "AllowRDP"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    depends_on             = [azurerm_resource_group.avd_net_rg]
}

resource "azurerm_network_security_group" "ad_nsg" {
    name                  = "${var.env}-ad-NSG"
    location              = azurerm_resource_group.avd_net_rg.location
    resource_group_name   = azurerm_resource_group.avd_net_rg.name
    security_rule {
        name                       = "AllowRDP"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    depends_on             = [azurerm_resource_group.avd_net_rg]
}

resource "azurerm_subnet_network_security_group_association" "avd_subnet_nsg" {
    subnet_id                 = azurerm_subnet.avd_subnet.id
    network_security_group_id = azurerm_network_security_group.avd_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "ad_subnet_nsg" {
    subnet_id                 = azurerm_subnet.ad_subnet.id
    network_security_group_id = azurerm_network_security_group.ad_nsg.id
}

/*
    Private endpoints
    Creates an Azure Private DNS zone: privatelink.blob.core.windows.net
    Associates the private DNS zone with the already created VNet to allow for private DNS to work correctly
    The private dns zone name is predefined depending on use
    Naming ref: https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration
*/

# blob
resource "azurerm_private_dns_zone" "pep_blob_private_dns_zone" {
  name = var.private_dns_zone_blob
  resource_group_name = azurerm_resource_group.avd_net_rg.name
}

# vnet link for storage private endpoints
resource "azurerm_private_dns_zone_virtual_network_link" "pep_blob_vnet_link" {
  name = "${var.env}-sa-pep-blob-vnetlink"
  resource_group_name = azurerm_resource_group.avd_net_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pep_blob_private_dns_zone.name
  virtual_network_id = azurerm_virtual_network.avd_spoke_vnet.id
}

# file
resource "azurerm_private_dns_zone" "pep_file_private_dns_zone" {
  name = var.private_dns_zone_file
  resource_group_name = azurerm_resource_group.avd_net_rg.name
}

# vnet link for storage private endpoints
resource "azurerm_private_dns_zone_virtual_network_link" "pep_file_vnet_link" {
  name = "${var.env}-sa-pep-file-vnetlink"
  resource_group_name = azurerm_resource_group.avd_net_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pep_file_private_dns_zone.name
  virtual_network_id = azurerm_virtual_network.avd_spoke_vnet.id
}