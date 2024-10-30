#variables for predefined infra resources
variable "az_subscription_id" {
    type        = string
    description = "subscription where all resources will be deployed"
    default     = "7067c10b-198e-4dda-a805-1a20f7595ee8"
}

variable "avd_env" {
    type        = string
    description = "environment that will be built if invoked"
    default     = "prod"
}

variable "prefix" {
    type    = string
    default = "grs_avd"
}

#env variables for build
variable "location" {
    type    = string
    default = "eastus"
}

variable "avd_prod_rg" {
    type        = string
    description = "resource group where all avd infra will be stored"
    default     = "grs-avd-prod-rg"
} 

/*
variable "dns_servers" {
    type        = list(string)
    description = "DNS severs"
    default     = ["168.63.129.16"]
}
*/
#Networking variables
variable "vnet_name" {
    type        = string
    description = "name avd vnet"
    default     = "avd-vnet"
}

variable "subnet_name" {
    type        = string
    description = "avd subnet name"
    default     = "avd-subnet"
}

variable "vnet_address_space" {
    type        = list(string)
    description = "full subnet IP range for vnet"
    default     = ["10.0.48.0/20"]
}

variable "subnet_address_prefix" {
    type        = list(string)
    description = "AVD service subnet"
    default     = ["10.0.50.0/24"]
}

#Storage account variables
variable "fslogix_file_storage_account_name" {
    type        = string
    description = "fslogix file storage account"
    default     = "$grsavdfslogixprofilestorage"
}

variable "file_storage_account_name" {
    type        = string
    description = "profile storage account"
    default     = "grsavdprofilestorage"
}

variable "fslogix_share_name" {
    type        = string
    description = "fslogix share name"
    default     = "fxlogicsprod"
}

variable "file_share_name" {
    type        = string
    description = "share name for avd profiles"
    default     = "avdprofiles"
}

# AVD Pool parameters
# Prod Pool
variable "avd_prod_workspace" {
    type = string
    description = "workspace name"
    default = "avd_prod_workspace"
}

variable "avd_prod_pool_name" {
    type = string
    description = "Production pool name"
    default     = "avd-prod-pool"
}

variable "avd_prod_pool_friendly_name" {
    type        = string
    description = "Production pool friendly name"
    default     = "AVD Production Host Pool"
}

variable "avd_prod_pool_loadbalancer" {
    type        = string
    description = "Prod pool load balancer type"
    default     = "BreadthFirst"
}

variable "avd_prod_pool_max_session_limit" {
    type        = number
    description = "Prod pool max session limit"
    default     = 5
}

variable "avd_rotation_token_days" {
    type        = number
    description = "number of days for avd token rotation"
    default     = 30
}

variable "rfc3339" {
    type        = string
    default     = "2024-11-20T12:43:13Z"
    description = "Registration token expiration"
}

# prod session host
variable "avd_prod_session_host_count" {
    type        = number
    description = "Number of session hosts to deploy"
    default     = 2
}

variable "avd_prod_session_host_name" {
    type        = string
    description = "session host name"
    default     = "avd-prod-session-host"
}

variable "avd_prod_session_host_nic_name" {
    type        = string
    description = "session host nic name"
    default     = "avd-prod-session-host-nic"
}

variable "avd_prod_session_host_vm_size" {
    type        = string
    description = "azure vm offering size"
    default     = "Standard_DC1s_v2"
}

variable "avd_prod_session_host_image_publisher" {
    type = string
    description = "os storage image reference"
    default = "MicrosoftWindowsDesktop"
}

variable "avd_prod_session_host_image_offer" {
    type = string
    description = "os storage image offer"
    default = "Windows-11"
}

variable "avd_prod_session_host_image_sku" {
    type = string
    description = "os storage image sky"
    default = "win11-22h2-avd"
}

variable "avd_prod_session_host_os_profile_user" {
    type = string
    description = "os admin user"
    default = "adminuser"
}

variable "avd_prod_session_host_os_profile_password" {
    type = string
    description = "os admin user"
    default = "Early-Autum_Flowers#"
    sensitive = true
}

# UAT Pool