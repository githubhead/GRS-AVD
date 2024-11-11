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

resource "random_uuid" "avd_random_uuid" {
}

# For the autoscale to work we need a custom AAD role and assign it to the Azure Virtual Desktop service
data "azurerm_role_definition" "autoscale_power_role" {
  name = "Desktop Virtualization Power On Off Contributor"
  
}

data "azurerm_subscription" "current" {
}

data "azuread_service_principal" "avd_autoscale_spn" {
  display_name = "Azure Virtual Desktop"
}

# Assign role created
resource "azurerm_role_assignment" "avd_autoscale_role_assignment" {
  principal_id                     = data.azuread_service_principal.avd_autoscale_spn.object_id
  scope                            = data.azurerm_subscription.current.id
  role_definition_id               = data.azurerm_role_definition.autoscale_power_role.id
  
  lifecycle {
    ignore_changes = [ role_definition_id ]
  }
}

# Create Workspace for AVD pools
resource "azurerm_virtual_desktop_workspace" "avd_workspace" {
    name                = "${var.env}-${var.avd_workspace}"
    resource_group_name = azurerm_resource_group.avd_compute_rg.name
    location            = azurerm_resource_group.avd_compute_rg.location
    friendly_name       = "${upper(var.env)} AVD Workspace"
    description         = "${upper(var.env)} AVD Workspace"
}

# Create AVD host pool
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

# Create desktop application group (DAG)
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

#Create scaling plan
resource "azurerm_virtual_desktop_scaling_plan" "avd_scaling_plan" {
  name = "${var.env}-${var.avd_scaling_plan_name}"
  location = azurerm_resource_group.avd_compute_rg.location
  resource_group_name = azurerm_resource_group.avd_compute_rg.name
  friendly_name = "${upper(var.env)}-${var.avd_scaling_plan_friendlyname}"
  description = "${var.env} Scaling Plan for week and weekends"
  time_zone = var.avd_scaling_plan_timezone
  host_pool {
    hostpool_id = azurerm_virtual_desktop_host_pool.avd_hostpool.id
    scaling_plan_enabled = true
  }
  schedule {
        name = "${var.env}-${var.avd_scaling_plan_weekday_name}"
        days_of_week = var.avd_scaling_plan_weekday_days
        ramp_up_start_time = var.avd_scaling_plan_weekday_ramp_up_start_time
        ramp_up_load_balancing_algorithm     = var.avd_scaling_plan_weekday_ramp_up_lb_algo
        ramp_up_minimum_hosts_percent        = var.avd_scaling_plan_weekday_ramp_up_minimum_host_pct
        ramp_up_capacity_threshold_percent   = var.avd_scaling_plan_weekday_ramp_up_capacity_threshold_pct
        peak_start_time                      = var.avd_scaling_plan_weekday_ramp_up_peak_time
        peak_load_balancing_algorithm        = var.avd_scaling_plan_weekday_ramp_up_peak_lb_algo
        ramp_down_start_time                 = var.avd_scaling_plan_weekday_ramp_down_start_time
        ramp_down_load_balancing_algorithm   = var.avd_scaling_plan_weekday_ramp_down_lb_algo
        ramp_down_minimum_hosts_percent      = var.avd_scaling_plan_weekday_ramp_down_minimum_host_pct
        ramp_down_force_logoff_users         = var.avd_scaling_plan_weekday_ramp_down_force_logoff
        ramp_down_wait_time_minutes          = var.avd_scaling_plan_weekday_ramp_down_wait_time
        ramp_down_notification_message       = var.avd_scaling_plan_weekday_ramp_down_notification_msg
        ramp_down_capacity_threshold_percent = var.avd_scaling_plan_weekday_ramp_down_capacity_threshold_pct
        ramp_down_stop_hosts_when            = var.avd_scaling_plan_weekday_ramp_down_stop_hosts_when
        off_peak_start_time                  = var.avd_scaling_plan_weekday_off_peak_start_time
        off_peak_load_balancing_algorithm    = var.avd_scaling_plan_weekday_off_lb_algo
  }
  schedule {
        name = "${var.env}-${var.avd_scaling_plan_weekend_name}"
        days_of_week = var.avd_scaling_plan_weekend_days
        ramp_up_start_time = var.avd_scaling_plan_weekend_ramp_up_start_time
        ramp_up_load_balancing_algorithm     = var.avd_scaling_plan_weekend_ramp_up_lb_algo
        ramp_up_minimum_hosts_percent        = var.avd_scaling_plan_weekend_ramp_up_minimum_host_pct
        ramp_up_capacity_threshold_percent   = var.avd_scaling_plan_weekend_ramp_up_capacity_threshold_pct
        peak_start_time                      = var.avd_scaling_plan_weekend_ramp_up_peak_time
        peak_load_balancing_algorithm        = var.avd_scaling_plan_weekend_ramp_up_peak_lb_algo
        ramp_down_start_time                 = var.avd_scaling_plan_weekend_ramp_down_start_time
        ramp_down_load_balancing_algorithm   = var.avd_scaling_plan_weekend_ramp_down_lb_algo
        ramp_down_minimum_hosts_percent      = var.avd_scaling_plan_weekend_ramp_down_minimum_host_pct
        ramp_down_force_logoff_users         = var.avd_scaling_plan_weekend_ramp_down_force_logoff
        ramp_down_wait_time_minutes          = var.avd_scaling_plan_weekend_ramp_down_wait_time
        ramp_down_notification_message       = var.avd_scaling_plan_weekend_ramp_down_notification_msg
        ramp_down_capacity_threshold_percent = var.avd_scaling_plan_weekend_ramp_down_capacity_threshold_pct
        ramp_down_stop_hosts_when            = var.avd_scaling_plan_weekend_ramp_down_stop_hosts_when
        off_peak_start_time                  = var.avd_scaling_plan_weekend_off_peak_start_time
        off_peak_load_balancing_algorithm    = var.avd_scaling_plan_weekend_off_lb_algo
  }
}

# Create Session Host
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

# Assign role to Desktop Application Group
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


/*
Creating section to demonstrate applications configurations
These tasks however should probably be moved to their own repo as they are day-to-day tasks instead of infra build
*/
resource "azurerm_virtual_desktop_application_group" "remote_application" {
  name = "remote_application"
  location = azurerm_resource_group.avd_compute_rg.location
  resource_group_name = azurerm_resource_group.avd_compute_rg.name
  type = "RemoteApp"
  host_pool_id = azurerm_virtual_desktop_host_pool.avd_hostpool.id
  friendly_name = "TestAppGroup"
  description = "Test Application Group"
}

resource "azurerm_virtual_desktop_application" "app_adobe" {
  name = "adobe"
  application_group_id = azurerm_virtual_desktop_application_group.remote_application.id
  friendly_name = "Adobe Reader"
  description = "Basic Adobe Reader App"
  path = "C:\\Program Files (x86)\\Adobe\\Acrobat Reader DC\\Reader\\AcroRd32.exe"
  command_line_argument_policy = "DoNotAllow"
  command_line_arguments = "--incognito"
  show_in_portal = false
  icon_path = "C:\\Program Files (x86)\\Adobe\\Acrobat Reader DC\\Reader\\AcroRd32.exe"
  icon_index = 0
}