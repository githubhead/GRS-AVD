terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~>2.0"
        }
        azuread = {
            source = "hashicorp/azuread"
        }
        random = {
            source = "hashicorp/random"
        }
    }
}

provider "azurerm" {
    features {}
}