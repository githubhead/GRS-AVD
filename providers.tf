terraform {
  backend "azurerm" {
    resource_group_name      = "grs-state-rg"
    storage_account_name     = "grsstatesa"
    container_name           = "avdtfstate"
    key                      = "grsavd.tfstate"
    #access_key               = var.storageAccount_access_key
}

    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
        }
        azuread = {
            source = "hashicorp/azuread"
        }
        random = {
            source = "hashicorp/random"
        }
        local = {
            source = "hashicorp/local"
        }
        azapi = {
            source = "Azure/azapi"
        }
        time = {
            source = "hashicorp/time"
        }
    }
}

provider "azurerm" {
    features {}
    subscription_id = var.az_subscription_id
}