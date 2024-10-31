provider "azurerm" {
    features {}
    subscription_id = var.az_subscription_id
}

#create resource group to aggregate all avd network components
resource "azurerm_resource_group" "avd_net_rg" {
    name     = "${var.env}-${var.avd_net_rg}"
    location = var.location
}

# create avd virtual network
resource "azurerm_virtual_network" "avd_vnet" {
    name                = "${var.env}-${var.vnet_name}"
    address_space       = var.vnet_address_space
    #dns_servers         = var.dns_servers
    resource_group_name = azurerm_resource_group.avd_net_rg.name
    location            = azurerm_resource_group.avd_net_rg.location
    depends_on          = [ azurerm_resource_group.avd_net_rg ]
}

resource "azurerm_subnet" "avd_subnet" {
    name                 = "${var.env}-${var.subnet_name}"
    resource_group_name  = azurerm_resource_group.avd_net_rg.name
    virtual_network_name = azurerm_virtual_network.avd_vnet.name
    address_prefixes     = var.subnet_address_prefix
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

resource "azurerm_subnet_network_security_group_association" "avd_subnet_nsg" {
    subnet_id                 = azurerm_subnet.avd_subnet.id
    network_security_group_id = azurerm_network_security_group.avd_nsg.id
}