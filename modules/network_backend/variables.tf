
#env variables for build
variable "location" {
    type        = string
    description = "Primary Azure zone for deployment"
}

variable "env" {
    type    = string
    description = "Type of environment to build i.e. dev/uat/prod"
}

variable "avd_net_rg" {
    type        = string
    description = "resource group where all avd network infra will be stored"
} 

#Networking variables
variable "vnet_spoke_name" {
    type        = string
    description = "string for name of avd vnet"
}

variable "vnet_spoke_address_space" {
    type        = list(string)
    description = "full subnet IP range for vnet"
}

variable "avd_subnet_name" {
    type        = string
    description = "string for avd subnet name"
}

variable "ad_subnet_name" {
    type        = string
    description = "string for avd subnet name"
}

variable "ad_subnet_address_prefix" {
    type        = list(string)
    description = "AD service subnet"
}

variable "avd_subnet_address_prefix" {
    type        = list(string)
    description = "AVD service subnet"
}

variable "dns_servers" {
    type        = list(string)
    description = "DNS severs for deployed VMs"
    #default    = ["168.63.129.16"]
}

# private endpoints
variable "private_dns_zone_blob" {   
    type        = string
    description = "MS predefined private dns zone name for blob storage"
}

variable "private_dns_zone_file" {   
    type        = string
    description = "MS predefined private dns zone name for file storage"
}