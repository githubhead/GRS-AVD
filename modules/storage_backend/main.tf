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
      directory_type = "AADKERB"
    }
}

resource azurerm_storage_share "profiles_share" {
    name                 = "${var.env}${var.profiles_share_name}"
    storage_account_id   = azurerm_storage_account.profiles_sa.id
    quota                = 1024
    depends_on           = [ azurerm_storage_account.profiles_sa ]
}

resource "azurerm_storage_share" "fslogix" {
    name                 = "${var.env}${var.fslogix_share_name}"
    storage_account_id   = azurerm_storage_account.profiles_sa.id
    quota                = 1024
    depends_on           = [ azurerm_storage_account.profiles_sa ]
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
      directory_type = "AADKERB"
    }
}

resource "azurerm_storage_share" "common_share" {
    name               = "${var.env}${var.common_share_name}"
    storage_account_id = azurerm_storage_account.fs_sa.id
    quota              = 1024
    depends_on         = [ azurerm_storage_account.fs_sa ]
}