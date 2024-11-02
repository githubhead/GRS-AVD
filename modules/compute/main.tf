provider "azurerm" {
    features {}
    subscription_id = var.az_subscription_id
}

data "azurerm_subnet" "avdsubnet" {
    name                 = var.avd_subnet
    virtual_network_name = var.avd_vnet
    resource_group_name  = var.avd_network_rg
}

# Assumes only one subnet exist in the vnet. 
# If querying a vnet with multiple subnets, will need to use data.azurerm_subnet.<dataobjectname>.*.id and use logic to parse through the array when using the output
output "avd_subnet_ids" {
    value                = "${data.azurerm_subnet.avdsubnet.id}"
}

# AVD Pools Resources
# PROD
# AVD Workspace
resource "azurerm_resource_group" "avd_compute_rg" {
    name     = "${var.env}-${var.avd_compute_rg}"
    location = var.location
}

resource "azurerm_virtual_desktop_workspace" "avd_workspace" {
    name                = "${var.env}-${var.avd_workspace}"
    resource_group_name = azurerm_resource_group.avd_compute_rg.name
    location            = azurerm_resource_group.avd_compute_rg.location
    friendly_name       = "${var.env} AVD Workspace"
    description         = "${var.env} AVD Workspace"
}

# AVD host pool
resource azurerm_virtual_desktop_host_pool "avd_hostpool" {
    name                     = "${var.env}-${var.avd_pool_name}"
    location                 = azurerm_resource_group.avd_compute_rg.location
    resource_group_name      = azurerm_resource_group.avd_compute_rg.name
    friendly_name            = "${var.env}-${var.avd_pool_friendly_name}"
    load_balancer_type       = var.avd_pool_loadbalancer
    type                     = "Pooled"
    maximum_sessions_allowed = var.avd_pool_max_session_limit
    validate_environment     = true
    description = "${var.env} AVD HostPool"
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "avd_hostpool_regitration_info" {
    hostpool_id     = azurerm_virtual_desktop_host_pool.avd_hostpool.id
    expiration_date = var.rfc3339
}

resource azurerm_virtual_desktop_application_group "avd_app_group" {
    name                = "${var.env}-${var.avd_pool_name}-app-group"
    resource_group_name = azurerm_resource_group.avd_compute_rg.name
    location            = azurerm_resource_group.avd_compute_rg.location
    host_pool_id        = azurerm_virtual_desktop_host_pool.avd_hostpool.id
    type                = "Desktop"
}

# Workspace and app group association
resource "azurerm_virtual_desktop_workspace_application_group_association" "avd_workspace_app_group_assoc" {
    application_group_id = azurerm_virtual_desktop_application_group.avd_app_group.id
    workspace_id = azurerm_virtual_desktop_workspace.avd_workspace.id
}

# Session Host
locals {
    registration_token = azurerm_virtual_desktop_host_pool_registration_info.avd_hostpool_regitration_info.token
}

resource "random_string" "prod_avd_local_password" {
    count = var.avd_session_host_count
    length = 16
    special = true
    min_special = 3
    override_special = "*@!?"
}

resource azurerm_network_interface "avd_hostpool_nic" {
    count = var.avd_session_host_count
    name = "${var.avd_session_host_nic_name}-${count.index + 1}"
    location = azurerm_resource_group.avd_compute_rg.location
    resource_group_name = azurerm_resource_group.avd_compute_rg.name

    ip_configuration {
      name = "nic${count.index + 1}_config"
      subnet_id = data.azurerm_subnet.avdsubnet.id
      private_ip_address_allocation = "Dynamic"
    }

    depends_on = [ 
        azurerm_resource_group.avd_compute_rg
    ]
}

resource "azurerm_windows_virtual_machine" "avd_hostpool_session_host" {
    count = var.avd_session_host_count
    name = "${var.env}avd${count.index + 1}"
    location = azurerm_resource_group.avd_compute_rg.location
    resource_group_name = azurerm_resource_group.avd_compute_rg.name
    size = var.avd_session_host_vm_size
    admin_username = var.avd_session_host_os_profile_user
    admin_password = var.avd_session_host_os_profile_password
    provision_vm_agent = true
    network_interface_ids = [
        "${azurerm_network_interface.avd_hostpool_nic.*.id[count.index]}"
    ]

    source_image_reference {
      publisher = var.avd_session_host_image_publisher
      offer = var.avd_session_host_image_offer
      sku = var.avd_session_host_image_sku
      version = "latest"
    }

    os_disk {
      name = "${var.env}-os${count.index + 1}"
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }

    depends_on = [ 
        azurerm_resource_group.avd_compute_rg,
        azurerm_network_interface.avd_hostpool_nic
     ]
}

resource "time_rotating" "avd_token" {
    rotation_days = var.avd_rotation_token_days
}

/*
domain join, plus other post deployment configs
https://learn.microsoft.com/en-us/azure/developer/terraform/create-avd-session-host
*/
