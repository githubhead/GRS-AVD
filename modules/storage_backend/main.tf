# Creating data object to query subnet info for hosts
# Assumes only one subnet exist in the vnet. 
# If querying a vnet with multiple subnets, will need to use data.azurerm_subnet.<dataobjectname>.*.id and use logic to parse through the array when using the output
data "azurerm_subnet" "avdsubnet" {
    name                 = var.avd_subnet_name
    virtual_network_name = var.vnet_spoke_name
    resource_group_name  = var.avd_net_rg
}

#create resource group to aggregate all AVD storage components
resource "azurerm_resource_group" "avd_sa_rg" {
    name     = "${var.env}-${var.avd_sa_rg}"
    location = var.location
}


# Random string resource for storage account names
resource "random_string" "r_string" {
    keepers = {
      resource_group_name = azurerm_resource_group.avd_sa_rg.name
    }
    length  = 6
    upper   = false
    lower   = false
    numeric = true
    special = false
}

# Storage Resources
resource "azurerm_storage_account" "profiles_sa" {
    name                     = "${var.env}${var.profile_storage_account_name}${random_string.r_string.result}"
    resource_group_name      = azurerm_resource_group.avd_sa_rg.name
    location                 = azurerm_resource_group.avd_sa_rg.location
    min_tls_version          = var.storage_min_tls_version
    account_tier             = var.storage_account_tier
    account_replication_type = var.storage_account_replication_type
    account_kind             = "FileStorage"
    public_network_access_enabled = false
    #enable_https_traffic_only = true  #this fails at the moment. It may be related to this https://github.com/hashicorp/vscode-terraform/issues/1813
    identity {
      type = "SystemAssigned"
    }

    azure_files_authentication {
      directory_type                 = "AADKERB"
      default_share_level_permission = "StorageFileDataSmbShareReader"
    }

    network_rules {
      default_action             = "Deny"
      bypass                     = ["AzureServices"]
      virtual_network_subnet_ids = [ data.azurerm_subnet.avdsubnet.id ]
    }

    depends_on = [ data.azurerm_subnet.avdsubnet ]
}

resource azurerm_storage_share "profiles_share" {
    name                 = "${var.env}${var.profiles_share_name}"
    storage_account_id   = azurerm_storage_account.profiles_sa.id
    quota                = 1024
    depends_on           = [ azurerm_storage_account.profiles_sa ]
}

resource "azurerm_storage_account" "fslogix_sa" {
    name                     = "${var.env}${var.fslogix_storage_account_name}${random_string.r_string.result}"
    resource_group_name      = azurerm_resource_group.avd_sa_rg.name
    location                 = azurerm_resource_group.avd_sa_rg.location
    min_tls_version          = var.storage_min_tls_version
    account_tier             = var.storage_account_tier
    account_replication_type = var.storage_account_replication_type
    account_kind             = "FileStorage"
    public_network_access_enabled = false
    #enable_https_traffic_only = true  #this fails at the moment. It may be related to this https://github.com/hashicorp/vscode-terraform/issues/1813
    identity {
      type = "SystemAssigned"
    }

    azure_files_authentication {
      directory_type                 = "AADKERB"
      default_share_level_permission = "StorageFileDataSmbShareReader"
    }

    network_rules {
      default_action             = "Deny"
      bypass                     = ["AzureServices"]
      virtual_network_subnet_ids = [ data.azurerm_subnet.avdsubnet.id ]
    }

    depends_on = [ data.azurerm_subnet.avdsubnet ]
}

resource "azurerm_storage_share" "fslogix" {
    name                 = "${var.env}${var.fslogix_share_name}"
    storage_account_id   = azurerm_storage_account.fslogix_sa.id
    quota                = 1024
    depends_on           = [ azurerm_storage_account.fslogix_sa ]
}

# Creating a general fs storage account and common share, 
# but global file shares will need to be created and managed separately
resource "azurerm_storage_account" "fs_sa" {
    name                     = "${var.env}${var.file_storage_account_name}${random_string.r_string.result}"
    resource_group_name      = azurerm_resource_group.avd_sa_rg.name
    location                 = azurerm_resource_group.avd_sa_rg.location
    min_tls_version          = var.storage_min_tls_version
    account_tier             = var.storage_account_tier
    account_replication_type = var.storage_account_replication_type
    account_kind             = "FileStorage"
    public_network_access_enabled = false
    #enable_https_traffic_only = true  #this fails at the moment. It may be related to this https://github.com/hashicorp/vscode-terraform/issues/1813 
    identity {
      type = "SystemAssigned"
    }

    azure_files_authentication {
      directory_type                 = "AADKERB"
      default_share_level_permission = "None"
    }

    network_rules {
      default_action             = "Deny"
      bypass                     = ["AzureServices"]
      virtual_network_subnet_ids = [data.azurerm_subnet.avdsubnet.id]
    }

    depends_on = [ data.azurerm_subnet.avdsubnet ]
}

resource "azurerm_storage_share" "common_share" {
    name               = "${var.env}${var.common_share_name}"
    storage_account_id = azurerm_storage_account.fs_sa.id
    quota              = 1024
    enabled_protocol   = "SMB"
    depends_on         = [ azurerm_storage_account.fs_sa ]
}

# RBAC based access configurations
# create logic artifacts to pull and handle built in roles
data "azurerm_role_definition" "fs_admin_role" {
  name = var.fs_admin_role
}

data "azurerm_role_definition" "fs_rw_role" {
  name = var.fs_rw_role
}

data "azurerm_role_definition" "fs_ro_role" {
  name = var.fs_ro_role
}

# create logic artifacst to pull and handle AAD groups
data "azuread_group" "fs_fslogix_admin_group" {
  display_name = var.fs_fslogix_admin_group
}

data "azuread_group" "fs_fslogix_rw_group" {
  display_name = var.fs_fslogix_rw_group
}

data "azuread_group" "fs_profiles_admin_group" {
  display_name = var.fs_profiles_admin_group
}

data "azuread_group" "fs_profiles_rw_group" {
  display_name = var.fs_profiles_rw_group
}

data "azuread_group" "fs_common_admin_group" {
  display_name = var.fs_common_admin_group
}

data "azuread_group" "fs_common_rw_group" {
  display_name = var.fs_common_rw_group
}

data "azuread_group" "fs_common_ro_group" {
  display_name = var.fs_common_ro_group
}

# assign admin role to admin group in profiles
resource "azurerm_role_assignment" "fs_admin_role_fs_profiles_admin_group" {
  scope              = azurerm_storage_account.profiles_sa.id
  role_definition_id = data.azurerm_role_definition.fs_admin_role.id
  principal_id       = data.azuread_group.fs_profiles_admin_group.object_id
}

# assign admin role to admin group in fslogix
resource "azurerm_role_assignment" "fs_admin_role_fs_fslogixs_admin_group" {
  scope              = azurerm_storage_account.fslogix_sa.id
  role_definition_id = data.azurerm_role_definition.fs_admin_role.id
  principal_id       = data.azuread_group.fs_fslogix_admin_group.object_id
}

# assign admin role to admin group in common
resource "azurerm_role_assignment" "fs_admin_role_fs_common_admin_group" {
  scope              = azurerm_storage_account.fs_sa.id
  role_definition_id = data.azurerm_role_definition.fs_admin_role.id
  principal_id       = data.azuread_group.fs_common_admin_group.object_id
}

# assign rw role to rw group in profiles
resource "azurerm_role_assignment" "fs_rw_role_fs_profiles_rw_group" {
  scope              = azurerm_storage_account.profiles_sa.id
  role_definition_id = data.azurerm_role_definition.fs_rw_role.id
  principal_id       = data.azuread_group.fs_profiles_rw_group.object_id
}

# assign rw role to rw group in fslogix
resource "azurerm_role_assignment" "fs_rw_role_fs_fslogix_rw_group" {
  scope              = azurerm_storage_account.fslogix_sa.id
  role_definition_id = data.azurerm_role_definition.fs_rw_role.id
  principal_id       = data.azuread_group.fs_fslogix_rw_group.object_id
}

# assign rw role to rw group in common
resource "azurerm_role_assignment" "fs_rw_role_fs_common_rw_group" {
  scope              = azurerm_storage_account.fs_sa.id
  role_definition_id = data.azurerm_role_definition.fs_rw_role.id
  principal_id       = data.azuread_group.fs_common_rw_group.object_id
}

# assign ro role to ro group in common
resource "azurerm_role_assignment" "fs_ro_role_fs_common_ro_group" {
  scope              = azurerm_storage_account.fs_sa.id
  role_definition_id = data.azurerm_role_definition.fs_ro_role.id
  principal_id       = data.azuread_group.fs_common_ro_group.object_id
}