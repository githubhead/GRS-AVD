terraform {
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