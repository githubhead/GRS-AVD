# Creating data object to query subnet info for hosts
data "azurerm_subnet" "avdsubnet" {
    name                 = var.avd_subnet_name
    virtual_network_name = var.vnet_spoke_name
    resource_group_name  = var.avd_net_rg
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
    friendly_name       = "${upper(var.env)} AVD Workspace"
    description         = "${upper(var.env)} AVD Workspace"
}

# AVD host pool
resource azurerm_virtual_desktop_host_pool "avd_hostpool" {
    resource_group_name      = azurerm_resource_group.avd_compute_rg.name
    name                     = "${var.env}-${var.avd_pool_name}"
    location                 = azurerm_resource_group.avd_compute_rg.location
    friendly_name            = "${upper(var.env)}-${var.avd_pool_friendly_name}"
    description              = "${upper(var.env)} AVD HostPool"
    load_balancer_type       = var.avd_pool_loadbalancer
    custom_rdp_properties    = var.avd_pool_custom_rdp_properties
    type                     = "Pooled"
    maximum_sessions_allowed = var.avd_pool_max_session_limit
    validate_environment     = true
    start_vm_on_connect      = true
    
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "avd_hostpool_regitration_info" {
    hostpool_id     = azurerm_virtual_desktop_host_pool.avd_hostpool.id
    expiration_date = timeadd(timestamp(), var.avd_pool_registation_expiration)
}

resource azurerm_virtual_desktop_application_group "avd_app_group" {
    name                         = "${var.env}-${var.avd_pool_name}-app-group"
    resource_group_name          = azurerm_resource_group.avd_compute_rg.name
    location                     = azurerm_resource_group.avd_compute_rg.location
    host_pool_id                 = azurerm_virtual_desktop_host_pool.avd_hostpool.id
    type                         = "Desktop"
    friendly_name                = "${upper(var.env)} AVD Desktop Application group"
    default_desktop_display_name = "${upper(var.env)} AVD Desktop"
    depends_on                   = [ azurerm_virtual_desktop_host_pool.avd_hostpool ]
}

# Workspace and Desktop Application Group (DAG) association
resource "azurerm_virtual_desktop_workspace_application_group_association" "avd_workspace_app_group_assoc" {
    application_group_id = azurerm_virtual_desktop_application_group.avd_app_group.id
    workspace_id         = azurerm_virtual_desktop_workspace.avd_workspace.id
}

# Session Host
locals {
    registration_token = azurerm_virtual_desktop_host_pool_registration_info.avd_hostpool_regitration_info.token
}

resource "random_string" "prod_avd_local_password" {
    count            = var.avd_session_host_count
    length           = 16
    special          = true
    min_special      = 3
    override_special = "*@!?"
}

resource azurerm_network_interface "avd_hostpool_nic" {
    count               = var.avd_session_host_count
    name                = "${var.avd_session_host_nic_name}-${count.index + 1}"
    location            = azurerm_resource_group.avd_compute_rg.location
    resource_group_name = azurerm_resource_group.avd_compute_rg.name

    ip_configuration {
      name                          = "nic${count.index + 1}_config"
      subnet_id                     = data.azurerm_subnet.avdsubnet.id
      private_ip_address_allocation = "Dynamic"
    }

    depends_on = [ 
        azurerm_resource_group.avd_compute_rg
    ]
}

resource "azurerm_windows_virtual_machine" "avd_hostpool_session_host" {
    count                 = var.avd_session_host_count
    name                  = "${var.env}avd${count.index + 1}"
    location              = azurerm_resource_group.avd_compute_rg.location
    resource_group_name   = azurerm_resource_group.avd_compute_rg.name
    size                  = var.avd_session_host_vm_size
    admin_username        = var.avd_session_host_os_profile_user
    admin_password        = var.avd_session_host_os_profile_password
    provision_vm_agent    = true
    network_interface_ids = [
        "${azurerm_network_interface.avd_hostpool_nic.*.id[count.index]}"
    ]

    source_image_reference {
      publisher = var.avd_session_host_image_publisher
      offer     = var.avd_session_host_image_offer
      sku       = var.avd_session_host_image_sku
      version   = "latest"
    }

    os_disk {
      name = "${var.env}-os${count.index + 1}"
      caching              = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }

    identity {
      type = "SystemAssigned"
    }

    depends_on = [ 
        azurerm_resource_group.avd_compute_rg,
        azurerm_network_interface.avd_hostpool_nic
     ]
}

# Join VMs to Entra ID
resource "azurerm_virtual_machine_extension" "aad_login" {
  count                = var.avd_session_host_count
  name                 = "AADLogin"
  virtual_machine_id   = azurerm_windows_virtual_machine.avd_hostpool_session_host.*.id[count.index]
  publisher            = "Microsoft.Azure.ActiveDirectory"
  type                 = "AADLoginForWindows" # For Linux VMs: AADSSHLoginForLinux
  type_handler_version = "1.0" # Check every once in a while to see if there is a more recent version
}

#Add VMs to Hostpool
resource "azurerm_virtual_machine_extension" "vmext_dsc" {
  count                      = var.avd_session_host_count
  name                       = "${var.env}${count.index + 1}-avd_dsc"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_hostpool_session_host.*.id[count.index]
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true

  settings = <<-SETTINGS
    {
      "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_09-08-2022.zip",
      "configurationFunction": "Configuration.ps1\\AddSessionHost",
      "properties": {
        "HostPoolName":"${azurerm_virtual_desktop_host_pool.avd_hostpool.name}"
      }
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "${local.registration_token}"
    }
  }
PROTECTED_SETTINGS

  depends_on = [
    azurerm_virtual_machine_extension.aad_login,
    azurerm_virtual_desktop_host_pool.avd_hostpool
  ]
}

# RBAC Configurations for VMs and application group
# Define role for vm login
data "azurerm_role_definition" "vm_user_login_role" { # access an existing built-in role
  name = var.vm_user_login_role_name
}

data "azuread_group" "avd_aad_group" {
  display_name = var.avd_aad_group_name
}

/*
resource "azuread_group" "avd_aad_group" {
  display_name     = var.avd_aad_group_name
  security_enabled = true
}
*/

# Assign tole to Desktop Application Group
resource "azurerm_role_assignment" "appgroup_role_assignment" {
  scope              = azurerm_virtual_desktop_application_group.avd_app_group.id
  role_definition_id = data.azurerm_role_definition.vm_user_login_role.id
  principal_id       = data.azuread_group.avd_aad_group.object_id
}

# Assign user log in role to Host Session VMs (required for Entra ID joined VMs)
resource "azurerm_role_assignment" "vm_userlogin_role_assignment" {
  count              = var.avd_session_host_count
  scope              = azurerm_windows_virtual_machine.avd_hostpool_session_host.*.id[count.index]
  role_definition_id = data.azurerm_role_definition.vm_user_login_role.id
  principal_id       = data.azuread_group.avd_aad_group.object_id
}

# Assign AAD Group to the Desktop Application Group (DAG)
resource "azurerm_role_assignment" "AVDGroupDesktopAssignment" {
  scope                = azurerm_virtual_desktop_application_group.avd_app_group.id
  role_definition_name = var.desktop_virtualization_role_name
  principal_id         = data.azuread_group.avd_aad_group.object_id
}

# Assign AAD Group to the Resource Group for RBAC for the Session Host
resource "azurerm_role_assignment" "RBACAssignment" {
  scope                = azurerm_resource_group.avd_compute_rg.id
  role_definition_name = var.vm_user_login_role_name
  principal_id         = data.azuread_group.avd_aad_group.object_id
}

/*
#Domain Join
resource "azurerm_virtual_machine_extension" "domain_join" {
    count                      = var.avd_session_host_count
    name                       = "${var.env}-${count.index + 1}-domainJoin"
    virtual_machine_id         = azurerm_windows_virtual_machine.avd_hostpool_session_host.*.id[count.index]
    publisher                  = "Microsoft.Compute"
    type                       = "JsonADDomainExtension"
    type_handler_version       = "1.3"
    auto_upgrade_minor_version = true

    settings = <<SETTINGS
      {
        "Name" : "${var.domain_name}",
        "OUPath" : "${var.ou_path}",
        "User" : "${var.domain_user_upn}@${var.domain_name}",
        "Restart" : "true",
        "Options" : "3"
      }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "Password": "${var.domain_password}"
    }
PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [ settings, protected_settings ]
  }

  depends_on = [  ]
}

resource "azurerm_virtual_machine_extension" "vmext_dsc" {
    count                      = var.avd_session_host_count
    name                       = "${var.env}${count.index + 1}-avd_dsc"
    virtual_machine_id         = azurerm_windows_virtual_machine.avd_hostpool_session_host.*.id[count.index]
    publisher                  = "Microsoft.Powershell"
    type                       = "DSC"
    type_handler_version       = "2.73"
    auto_upgrade_minor_version = true

    settings = <<SETTINGS
      {
        "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_09-08-2022.zip",
        "configurationFunction": "Configuration.ps1\\AddSessionHost",
        "properties": {
          "HostPoolName":"${azurerm_virtual_desktop_host_pool.avd_hostpool.name}"
        }
      }
SETTINGS

    protected_settings = <<PROTECTED_SETTINGS
    {
      "properties": {
        "registrationInfoToken": "${local.registration_token}"
      }
    }
PROTECTED_SETTINGS

    depends_on = [ 
        azurerm_virtual_machine_extension.domain_join,
        azurerm_virtual_desktop_host_pool.avd_hostpool
    ]
}
*/