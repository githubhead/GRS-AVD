provider "azurerm" {
    features {}
    subscription_id = var.az_subscription_id
}

#create resource group to aggregate all avd storage components
resource "azurerm_resource_group" "avd_sa_rg" {
    name     = "${var.env}-${var.avd_sa_rg}"
    location = var.location
}

# Storage Resources
resource "azurerm_storage_account" "fs_sa" {
    name                     = "${var.env}${var.file_storage_account_name}"
    resource_group_name      = azurerm_resource_group.avd_sa_rg.name
    location                 = azurerm_resource_group.avd_sa_rg.location
    account_tier             = var.storage_account_tier
    account_replication_type = var.storage_account_replication_type
    account_kind             = "FileStorage"
    #kind = "StorageV2"
}

resource azurerm_storage_share "fs_share" {
    name                 = var.file_share_name
    storage_account_name = azurerm_storage_account.fs_sa.name
    quota                = 5120
}

resource "azurerm_storage_share" "fslogix" {
    name                 = var.fslogix_share_name
    storage_account_name = azurerm_storage_account.fs_sa.name
    quota                = 1024
  
}
