#create resource group to aggregate all avd components
resource "azurerm_resource_group" "avd_rg" {
    name     = var.avd_prod_rg
    location = var.location
}


# create avd virtual network
resource "azurerm_virtual_network" "avd_vnet" {
    name                = var.vnet_name
    address_space       = var.vnet_address_space
    #dns_servers         = var.dns_servers
    location            = var.location
    resource_group_name = var.avd_prod_rg
    depends_on          = [ azurerm_resource_group.avd_rg ]
}

resource "azurerm_subnet" "avd_subnet" {
    name                 = var.subnet_name
    resource_group_name  = var.avd_prod_rg
    virtual_network_name = azurerm_virtual_network.avd_vnet.name
    address_prefixes     = var.subnet_address_prefix
    enforce_private_link_endpoint_network_policies = true
    depends_on           = [ azurerm_resource_group.avd_rg ]
}

resource "azurerm_network_security_group" "avd_nsg" {
    name                  = "${var.prefix}-NSG"
    location              = azurerm_resource_group.avd_rg.location
    resource_group_name   = var.avd_prod_rg
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
    depends_on             = [azurerm_resource_group.avd_rg]
}

resource "azurerm_subnet_network_security_group_association" "avd_subnet_nsg" {
    subnet_id                 = azurerm_subnet.avd_subnet.id
    network_security_group_id = azurerm_network_security_group.avd_nsg.id
}

# Storage Resources
resource "azurerm_storage_account" "file_storage" {
    name                     = var.file_storage_account_name
    resource_group_name      = var.avd_prod_rg
    location                 = azurerm_resource_group.avd_rg.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
    #kind = "StorageV2"
}

resource azurerm_storage_share "profile_share" {
    name                 = var.file_share_name
    storage_account_name = azurerm_storage_account.file_storage.name
    quota                = 5120
}

# AVD Pools Resources
# PROD
# AVD Workspace
resource "azurerm_virtual_desktop_workspace" "prod_workspace" {
    name = var.avd_prod_workspace
    resource_group_name = azurerm_resource_group.avd_rg.name
    location = azurerm_resource_group.avd_rg.location
    friendly_name = "${var.prefix} Prod Workspace"
    description = "${var.prefix} Prod Workspace"
}

# AVD host pool
resource azurerm_virtual_desktop_host_pool "prod_hostpool" {
    name                     = var.avd_prod_pool_name
    location                 = azurerm_resource_group.avd_rg.location
    resource_group_name      = azurerm_resource_group.avd_rg.name
    friendly_name            = var.avd_prod_pool_friendly_name
    load_balancer_type       = var.avd_prod_pool_loadbalancer
    type                     = "Pooled"
    maximum_sessions_allowed = var.avd_prod_pool_max_session_limit
    validate_environment     = true
    description = "${var.prefix} Prod HostPool"
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "prod_hostpool_regitration_info" {
    hostpool_id = azurerm_virtual_desktop_host_pool.prod_hostpool.id
    expiration_date = var.rfc3339
}

resource azurerm_virtual_desktop_application_group "prod_app_group" {
    name                = "${var.avd_prod_pool_name}-app-group"
    resource_group_name = azurerm_resource_group.avd_rg.name
    location            = azurerm_resource_group.avd_rg.location
    host_pool_id         = azurerm_virtual_desktop_host_pool.prod_hostpool.id
    type                = "Desktop"
}

# Workspace and app group association
resource "azurerm_virtual_desktop_workspace_application_group_association" "prod_workspace_app_group_assoc" {
    application_group_id = azurerm_virtual_desktop_application_group.prod_app_group.id
    workspace_id = azurerm_virtual_desktop_workspace.prod_workspace.id
}

# Session Host
locals {
    registration_token = azurerm_virtual_desktop_host_pool_registration_info.prod_hostpool_regitration_info.token
}

resource "random_string" "prod_avd_local_password" {
    count = var.avd_prod_session_host_count
    length = 16
    special = true
    min_special = 3
    override_special = "*@!?"
}

resource azurerm_network_interface "prod_hostpool_nic" {
    count = var.avd_prod_session_host_count
    name = "${var.avd_prod_session_host_nic_name}-${count.index + 1}"
    location = azurerm_resource_group.avd_rg.location
    resource_group_name = azurerm_resource_group.avd_rg.name

    ip_configuration {
      name = "nic${count.index + 1}_config"
      subnet_id = azurerm_subnet.avd_subnet.id
      private_ip_address_allocation = "dynamic"
    }

    depends_on = [ 
        azurerm_resource_group.avd_rg 
    ]
}

resource "azurerm_windows_virtual_machine" "prod_hostpool_session_host" {
    count = var.avd_prod_session_host_count
    name = "grsprod${count.index + 1}"
    location = azurerm_resource_group.avd_rg.location
    resource_group_name = azurerm_resource_group.avd_rg.name
    size = var.avd_prod_session_host_vm_size
    admin_username = var.avd_prod_session_host_os_profile_user
    admin_password = var.avd_prod_session_host_os_profile_password
    provision_vm_agent = true
    network_interface_ids = [
        "${azurerm_network_interface.prod_hostpool_nic.*.id[count.index]}"
    ]

    source_image_reference {
      publisher = var.avd_prod_session_host_image_publisher
      offer = var.avd_prod_session_host_image_offer
      sku = var.avd_prod_session_host_image_sku
      version = "latest"
    }

    os_disk {
      name = "${lower(var.prefix)}-${count.index + 1}"
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }

    depends_on = [ 
        azurerm_resource_group.avd_rg,
        azurerm_network_interface.prod_hostpool_nic
     ]
}

resource "time_rotating" "avd_token" {
    rotation_days = var.avd_rotation_token_days
}

/*
domain join, plus other post deployment configs
https://learn.microsoft.com/en-us/azure/developer/terraform/create-avd-session-host
*/
