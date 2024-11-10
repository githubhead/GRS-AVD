#env variables for build
variable "location" {
    type    = string
    description = "Primary Azure zone for deployment"
}

variable "env" {
    type    = string
}

variable "avd_compute_rg" {
    type        = string
    description = "resource group where all avd host and hostpool infra will be stored"
}

# Network dependencies for AVD pool
variable "avd_net_rg" {
    type        = string
    description = "predefined resource group for network resources. Will be referenced in data sources"
}

variable "avd_subnet_name" {
    type        = string
    description = "predefined subnet for avd network. Will be referenced in data sources"
}

variable "vnet_spoke_name" {
    type        = string
    description = "predefined virtual network. Will be referenced in data sources"
}

# AVD Pool parameters
# Prod Pool
variable "avd_workspace" {
    type        = string
    description = "workspace name"
}

variable "avd_pool_name" {
    type        = string
    description = "avd pool name"
}

variable "avd_pool_friendly_name" {
    type        = string
    description = "avd pool friendly name"
}

variable "avd_pool_loadbalancer" {
    type        = string
    description = "avd pool load balancer type"
}

variable "avd_pool_custom_rdp_properties" {
    type         = string
    default = "Custom RDP properties provided to sessions"
}

variable "avd_pool_max_session_limit" {
    type        = number
    description = "avd pool max session limit"
}

variable "avd_pool_registation_expiration" {
    type        = string
    description = "expiration in hours for desktop hostpool registation"
}

# prod session host
variable "avd_session_host_count" {
    type        = number
    description = "Number of session hosts to deploy"
}

variable "avd_session_host_name" {
    type        = string
    description = "session host name"
}

variable "avd_session_host_nic_name" {
    type        = string
    description = "session host nic name"
}

variable "avd_session_host_vm_size" {
    type        = string
    description = "azure vm offering size"
}

variable "avd_session_host_image_publisher" {
    type        = string
    description = "os storage image reference"
}

variable "avd_session_host_image_offer" {
    type        = string
    description = "os storage image offer"
}

variable "avd_session_host_image_sku" {
    type        = string
    description = "os storage image sky"
}

variable "avd_session_host_os_profile_user" {
    type        = string
    description = "os admin user"
}

variable "avd_session_host_os_profile_password" {
    type        = string
    description = "os admin password"
    sensitive   = true
}

variable "domain_name" {
    type        = string
    description = "domain name"
}

variable "ou_path" {
    type        = string
    description = "Ou path (optional)"
}

variable "domain_user_upn" {
    type        = string
    description = "domain user joiner"
}

variable "domain_password" {
    type        = string
    description = "domain user joiner pw"
    sensitive = true
}

variable "avd_aad_group_name" {
      type        = string
      description = "Entra ID Group to allow access to AVD"
}

variable "vm_user_login_role_name" {
    type        = string
    description = "Azure role for virtual machine user login"
}

variable "desktop_virtualization_role_name" {
    type        = string
    description = "Azure role for virtual machine user login"
}