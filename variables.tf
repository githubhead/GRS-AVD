#variables for predefined infra resources
variable "az_subscription_id" {
    type        = string
    description = "subscription where all resources will be deployed"
}

#env variables for build
variable "location" {
    type        = string
    description = "Primary Azure zone for deployment"
}

variable "env" {
    type    = string
}

variable "avd_net_rg" {
    type        = string
    description = "resource group where all avd network infra will be stored"
} 

#------------------------
# NETWORK COMPONENTS
#------------------------
variable "vnet_spoke_name" {
    type        = string
    description = "name string for avd vnet"
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
    description = "string for AD subnet name"
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
    description = "DNS severs"
    #default    = ["168.63.129.16"]
}

#------------------------
# STORAGE COMPONENTS
#------------------------
# Storage account resource group
variable "avd_sa_rg" {
    type        = string
    description = "resource group where all avd storage components will be stored"
} 

#Storage account variables
variable "profile_storage_account_name" {
    type        = string
    description = "fslogix file storage account"
}

variable "storage_min_tls_version" {
    type        = string
    description = "minimum TLS version for storage account"
}

variable "storage_account_tier" {
    type = string
    description = "Storage account tier"
}

variable "storage_account_replication_type" {
    type = string
    description = "Storage account replication type"
}

# File shares variables
variable "fslogix_share_name" {
    type        = string
    description = "fslogix share name"
}

variable "profiles_share_name" {
    type        = string
    description = "share name for avd profiles"
}

#creating a general fs storage account and common share, but global file shares will need to be created and managed separately
variable "file_storage_account_name" {
    type        = string
    description = "profile storage account"
}

variable "common_share_name" {   
    type        = string
    description = "common share name for testing"
}

#------------------------
# AVD COMPUTE COMPONENTS
#------------------------
variable "avd_compute_rg" {
    type        = string
    description = "resource group where all avd host and hostpool infra will be stored"
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