#adding sub here, but will centralize later
variable "az_subscription_id" {
    type        = string
    description = "subscription where all resources will be deployed"
    default     = "7067c10b-198e-4dda-a805-1a20f7595ee8"
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

variable "avd_sa_rg" {
    type        = string
    description = "resource group where all avd network infra will be stored"
    default     = "avd-stor-rg"
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

variable "storage_account_tier" {
    type = string
    description = "Storage account tier"
    default = "Premium"
}

variable "storage_account_replication_type" {
    type = string
    description = "Storage account replication type"
    default = "LRS"
}
