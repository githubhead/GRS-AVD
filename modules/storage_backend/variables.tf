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

# creating a general fs storage account and common share, but global file shares will need to be created and managed separately
variable "file_storage_account_name" {
    type        = string
    description = "profile storage account"
}

variable "common_share_name" {   
    type        = string
    description = "common share name for testing"
}
