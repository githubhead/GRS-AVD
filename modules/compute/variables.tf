#adding sub here, but will centralize later
variable "az_subscription_id" {
    type        = string
    description = "subscription where all resources will be deployed"
    default     = ""  #Enter at runtime
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

variable "avd_compute_rg" {
    type        = string
    description = "resource group where all avd host and hostpool infra will be stored"
    default     = "avd-compute-rg"
}

# Network dependencies for AVD pool
variable "avd_network_rg" {
    type        = string
    description = "predefined resource group for infrastructure resources. Will be referenced in data sources"
    default = "dev-avd-net-rg"
}

variable "avd_subnet" {
    type        = string
    description = "predefined subnet for infrastructure resources. Will be referenced in data sources"
    default = "dev-avd-subnet"
}

variable "avd_vnet" {
    type        = string
    description = "predefined subnet for infrastructure resources. Will be referenced in data sources"
    default = "dev-avd-vnet"
}

# AVD Pool parameters
# Prod Pool
variable "avd_workspace" {
    type = string
    description = "workspace name"
    default = "avd_workspace"
}

variable "avd_pool_name" {
    type = string
    description = "avd pool name"
    default     = "avd-pool"
}

variable "avd_pool_friendly_name" {
    type        = string
    description = "avd pool friendly name"
    default     = "AVD Production Host Pool"
}

variable "avd_pool_loadbalancer" {
    type        = string
    description = "avd pool load balancer type"
    default     = "BreadthFirst"
}

variable "avd_pool_max_session_limit" {
    type        = number
    description = "avd pool max session limit"
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
variable "avd_session_host_count" {
    type        = number
    description = "Number of session hosts to deploy"
    default     = 2
}

variable "avd_session_host_name" {
    type        = string
    description = "session host name"
    default     = "avd-session-host"
}

variable "avd_session_host_nic_name" {
    type        = string
    description = "session host nic name"
    default     = "avd-session-host-nic"
}

variable "avd_session_host_vm_size" {
    type        = string
    description = "azure vm offering size"
    default     = "Standard_DC1s_v2"
}

variable "avd_session_host_image_publisher" {
    type = string
    description = "os storage image reference"
    default = "MicrosoftWindowsDesktop"
}

variable "avd_session_host_image_offer" {
    type = string
    description = "os storage image offer"
    default = "Windows-11"
}

variable "avd_session_host_image_sku" {
    type = string
    description = "os storage image sky"
    default = "win11-22h2-avd"
}

variable "avd_session_host_os_profile_user" {
    type = string
    description = "os admin user"
    default = "adminuser"
}

variable "avd_session_host_os_profile_password" {
    type = string
    description = "os admin user"
    default = "Early-Autum_Flowers#"
    sensitive = true
}