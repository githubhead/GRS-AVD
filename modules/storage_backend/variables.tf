#env variables for build
variable "location" {
    type    = string
    description = "Primary Azure zone for deployment"
}

variable "env" {
    type    = string
    description = "Type of environment to build i.e. dev/uat/prod"
}

variable "avd_sa_rg" {
    type        = string
    description = "resource group where all avd storage components will be stored"
} 

# Network dependencies for storage network rules
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

#Storage account variables
variable "profile_storage_account_name" {
    type        = string
    description = "fslogix file storage account"
}

variable "fslogix_storage_account_name" {
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

# creating a general fs storage account and common share, but global file shares will need to be created and managed separately
variable "file_storage_account_name" {
    type        = string
    description = "profile storage account"
}

variable "common_share_name" {   
    type        = string
    description = "common share name for testing"
}

# FS RBAC Variables
# roles
variable "fs_admin_role" {   
    type        = string
    description = "Az built in role for SMB administration. Role: Storage File Data SMB Share Elevated Contributor"
}

variable "fs_rw_role" {   
    type        = string
    description = "Az built in role for SMB R/W access. Role: Storage File Data SMB Share Contributor"
}

variable "fs_ro_role" {   
    type        = string
    description = "Az built in role for SMB read-only access. Role: Storage File Data SMB Share Reader"
}

# groups
# fslogix
variable "fs_fslogix_admin_group" {   
    type        = string
    description = "FSLogix share administrators group"
}

variable "fs_fslogix_rw_group" {   
    type        = string
    description = "FSLogix share R/W access group"
}

# user profiles
variable "fs_profiles_admin_group" {   
    type        = string
    description = "User profiles share administrators group"
}

variable "fs_profiles_rw_group" {   
    type        = string
    description = "User profiles share R/W access group"
}

# common
variable "fs_common_admin_group" {   
    type        = string
    description = "Common share administrators group"
}

variable "fs_common_rw_group" {   
    type        = string
    description = "Common share R/W access group"
}

variable "fs_common_ro_group" {   
    type        = string
    description = "Common share read-only access group"
}