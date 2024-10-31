#create resource group to aggregate all avd components
resource "azurerm_resource_group" "avd_rg" {
    name     = var.avd_prod_rg
    location = var.location
}

