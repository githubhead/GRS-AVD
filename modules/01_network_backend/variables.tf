
#adding sub here, but will centralize later
variable "az_subscription_id" {
    type        = string
    description = "subscription where all resources will be deployed"
    default     = ""  #provide at runtime
}

#env variables for build
variable "location" {
    type    = string
    default = "eastus"
}

variable "env" {
    type    = string
    default = "dev"
}

variable "avd_net_rg" {
    type        = string
    description = "resource group where all avd network infra will be stored"
    default     = "avd-net-rg"
} 

#Networking variables
variable "vnet_name" {
    type        = string
    description = "name avd vnet"
    default     = "avd-vnet"
}

variable "avd_subnet_name" {
    type        = string
    description = "avd subnet name"
    default     = "avd-subnet"
}

variable "ad_subnet_name" {
    type        = string
    description = "avd subnet name"
    default     = "ad-subnet"
}

variable "vnet_address_space" {
    type        = list(string)
    description = "full subnet IP range for vnet"
    default     = ["10.0.48.0/20"]
}

variable "ad_subnet_address_prefix" {
    type        = list(string)
    description = "AVD service subnet"
    default     = ["10.0.49.0/24"]
}

variable "avd_subnet_address_prefix" {
    type        = list(string)
    description = "AVD service subnet"
    default     = ["10.0.50.0/24"]
}
/*
variable "dns_servers" {
    type        = list(string)
    description = "DNS severs"
    default     = ["168.63.129.16"]
}
*/