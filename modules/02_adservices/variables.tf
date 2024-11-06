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
    type        = string
    description = "Environment that will be deployed"
    default     = "dev"
}

variable "adsvcs_rg" {
    type        = string
    description = "resource group where all avd host and hostpool infra will be stored"
    default     = "adsvcs-rg"
}

# Network dependencies
variable "avd_network_rg" {
    type        = string
    description = "predefined resource group for infrastructure resources. Will be referenced in data sources"
    default     = "dev-avd-net-rg"
}

variable "avd_vnet" {
    type        = string
    description = "predefined subnet for infrastructure resources. Will be referenced in data sources"
    default     = "dev-avd-vnet"
}

variable "ad_subnet" {
    type        = string
    description = "predefined subnet for infrastructure resources. Will be referenced in data sources"
    default     = "dev-ad-subnet"
}

variable "virtual_machine_name" {
    type        = string
    description = "The name of the virtual machine."
    default     = "dc"
}

variable "os_flavor" {
    type        = string
    description = "Specify the flavor of the operating system image to deploy Virtual Machine. Valid values are `windows` and `linux`"
    default     = "windows"
}

variable "virtual_machine_size" {
    type        = string
    description = "The Virtual Machine SKU for the Virtual Machine, Default is Standard_A2_V2"
    default     = "Standard_DC1s_v2"
}

variable "instances_count" {
    type        = number
    description = "The number of Virtual Machines required."
    default     = 2
}

variable "enable_ip_forwarding" {
    type        = string
    description = "Should IP Forwarding be enabled? Defaults to false"
    default     = false
}

variable "enable_accelerated_networking" {
    type        = string
    description = "Should Accelerated Networking be enabled? Defaults to false."
    default     = false
}

variable "private_ip_address_allocation_type" {
    type        = string
    description = "The allocation method used for the Private IP Address. Possible values are Dynamic and Static."
    default     = "Static"
}

variable "private_ip_address" {
    type        = list(string)
    description = "The Static IP Address which should be used. This is valid only when `private_ip_address_allocation` is set to `Static` "
    default     = ["10.0.49.10","10.0.49.11"] 
}

variable "dns_servers" {
    description = "List of dns servers to use for network interface"
    default     = ["127.0.0.1"]
}

variable "enable_vm_availability_set" {
    type        = bool
    description = "Manages an Availability Set for Virtual Machines."
    default     = true
}

variable "platform_update_domain_count" {
    type        = number
    description = "Specifies the number of update domains that are used"
    default     = 5
}

variable "platform_fault_domain_count" {
    type        = number
    description = "Specifies the number of fault domains that are used"
    default     = 3
}

variable "enable_public_ip_address" {
    description = "Reference to a Public IP Address to associate with the NIC"
    default     = true
}

variable "source_image_id" {
    description = "The ID of an Image which each Virtual Machine should be based on"
  default     = null
}

variable "dc_image_publisher" {
    type        = string
    description = "dc image publisher"
    default     = "MicrosoftWindowsServer"
}

variable "dc_image_offer" {
    type        = string
    description = "dc image offer"
    default     = "WindowsServer"
}

variable "dc_image_sku" {
    type        = string
    description = "dc image sku"
    default     = "2022-datacenter-azure-edition-core"
}

variable "dc_image_version" {
    type        = string
    description = "dc image version"
    default     = "latest"
}

variable "windows_distribution_name" {
    type        = string
    default     = "windows2019dc"
    description = "Variable to pick an OS flavour for Windows based VM. Possible values include: winserver, wincore, winsql"
}

variable "os_disk_storage_account_type" {
    type        = string
    description = "The Type of Storage Account which should back this the Internal OS Disk. Possible values include Standard_LRS, StandardSSD_LRS and Premium_LRS."
    default     = "StandardSSD_LRS"
}

variable "admin_username" {
    type        = string
    description = "The username of the local administrator used for the Virtual Machine."
    default     = "azureadmin"
}

variable "admin_password" {
    type        = string
    description = "The Password which should be used for the local-administrator on this Virtual Machine"
    default     = "EverythingChangesAndSoWillThis!"
    sensitive   = true
}

variable "license_type" {
    type        = string
    description = "Specifies the type of on-premise license which should be used for this Virtual Machine. Possible values are None, Windows_Client and Windows_Server."
    default     = "None"
}

variable "active_directory_domain" {
    type        = string
    description = "The name of the Active Directory domain, for example `consoto.com`"
    default     = "grs.stone"
}

variable "active_directory_netbios_name" {
    type        = string
    description = "The netbios name of the Active Directory domain, for example `consoto`"
    default     = "grs"
}

variable "nsg_inbound_rules" {
    description = "List of NSG inbound rules allowed"
    default = [
    {
      name                   = "rdp"
      destination_port_range = "3389"
      source_address_prefix  = "*"
    },

    {
      name                   = "dns"
      destination_port_range = "53"
      source_address_prefix  = "*"
    }
  ]
}