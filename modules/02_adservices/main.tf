provider "azurerm" {
    features {}
    subscription_id = var.az_subscription_id
}

#-------------------------------
# Local Declarations
#-------------------------------
locals {
  nsg_inbound_rules = { for idx, security_rule in var.nsg_inbound_rules : security_rule.name => {
    idx : idx,
    security_rule : security_rule,
    }
  }

  import_command       = "Import-Module ADDSDeployment"
  password_command     = "$password = ConvertTo-SecureString ${var.admin_password} -AsPlainText -Force"
  install_ad_command   = "Install-WindowsFeature -Name AD-Domain-Services,DNS -IncludeManagementTools"
  configure_ad_command = "Install-ADDSForest -CreateDnsDelegation:$false -DomainMode Win2012R2 -DomainName ${var.active_directory_domain} -DomainNetbiosName ${var.active_directory_netbios_name} -ForestMode Win2012R2 -InstallDns:$true -SafeModeAdministratorPassword $password -Force:$true"
  shutdown_command     = "shutdown -r -t 60"
  exit_code_hack       = "exit 0"
  powershell_command   = "${local.import_command}; ${local.password_command}; ${local.install_ad_command}; ${local.configure_ad_command}; ${local.shutdown_command}; ${local.exit_code_hack}"
}

#----------------------------------------------------------
# Resource Group, VNet, Subnet selection & Random Resources
#----------------------------------------------------------

#create resource group to aggregate all AD components
resource "azurerm_resource_group" "adsvcs_rg" {
    name     = "${var.env}-${var.adsvcs_rg}"
    location = var.location
}

# Creating data object to query subnet info for hosts
data "azurerm_subnet" "adsubnet" {
    name                 = var.ad_subnet
    virtual_network_name = var.avd_vnet
    resource_group_name  = var.avd_network_rg
}

# Assumes only one subnet exist in the vnet. 
# If querying a vnet with multiple subnets, will need to use data.azurerm_subnet.<dataobjectname>.*.id and use logic to parse through the array when using the output
output "avd_subnet_ids" {
    value                = "${data.azurerm_subnet.adsubnet.id}"
}

resource "random_string" "str" {
  count   = var.enable_public_ip_address == true ? var.instances_count : 0
  length  = 6
  special = false
  upper   = false
  keepers = {
    domain_name_label = var.virtual_machine_name
  }
}

#-----------------------------------
# Public IP for Virtual Machine
#-----------------------------------
resource "azurerm_public_ip" "dc_pip" {
  count               = var.enable_public_ip_address == true ? var.instances_count : 0
  name                = lower("pip-vm-${var.virtual_machine_name}-${azurerm_resource_group.adsvcs_rg.location}-0${count.index + 1}")
  location            = azurerm_resource_group.adsvcs_rg.location
  resource_group_name = azurerm_resource_group.adsvcs_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = format("%s%s", lower(replace(var.virtual_machine_name, "/[[:^alnum:]]/", "")), random_string.str[count.index].result)
  #tags                = merge({ "ResourceName" = lower("pip-vm-${var.virtual_machine_name}-${data.azurerm_resource_group.rg.location}-0${count.index + 1}") }, var.tags, )
}

#---------------------------------------
# Network Interface for Virtual Machine
#---------------------------------------
resource "azurerm_network_interface" "dc_nic" {
  count                         = var.instances_count
  name                          = var.instances_count == 1 ? lower("nic-${format("vm%s", lower(replace(var.virtual_machine_name, "/[[:^alnum:]]/", "")))}") : lower("nic-${format("vm%s%s", lower(replace(var.virtual_machine_name, "/[[:^alnum:]]/", "")), count.index + 1)}")
  resource_group_name           = azurerm_resource_group.adsvcs_rg.name
  location                      = azurerm_resource_group.adsvcs_rg.location
  dns_servers                   = var.dns_servers
  #tags                          = merge({ "ResourceName" = var.instances_count == 1 ? lower("nic-${format("vm%s", lower(replace(var.virtual_machine_name, "/[[:^alnum:]]/", "")))}") : lower("nic-${format("vm%s%s", lower(replace(var.virtual_machine_name, "/[[:^alnum:]]/", "")), count.index + 1)}") }, var.tags, )

  ip_configuration {
    name                          = lower("ipconig-${format("vm%s%s", lower(replace(var.virtual_machine_name, "/[[:^alnum:]]/", "")), count.index + 1)}")
    primary                       = true
    subnet_id                     = data.azurerm_subnet.adsubnet.id
    private_ip_address_allocation = var.private_ip_address_allocation_type
    private_ip_address            = var.private_ip_address_allocation_type == "Static" ? element(concat(var.private_ip_address, [""]), count.index) : null
    public_ip_address_id          = var.enable_public_ip_address == true ? element(concat(azurerm_public_ip.dc_pip.*.id, [""]), count.index) : null
  }
}

resource "azurerm_availability_set" "dc_aset" {
  count                        = var.enable_vm_availability_set ? 1 : 0
  name                         = lower("avail-${var.virtual_machine_name}-${azurerm_resource_group.adsvcs_rg.location}")
  resource_group_name          = azurerm_resource_group.adsvcs_rg.name
  location                     = azurerm_resource_group.adsvcs_rg.location
  platform_fault_domain_count  = var.platform_fault_domain_count
  platform_update_domain_count = var.platform_update_domain_count
  managed                      = true
  #tags                         = merge({ "ResourceName" = lower("avail-${var.virtual_machine_name}-${data.azurerm_resource_group.rg.location}") }, var.tags, )
}

#---------------------------------------------------------------
# Network security group for Virtual Machine Network Interface
#---------------------------------------------------------------
resource "azurerm_network_security_group" "dc_nsg" {
  name                = lower("nsg_${var.virtual_machine_name}_${azurerm_resource_group.adsvcs_rg.location}_in")
  resource_group_name = azurerm_resource_group.adsvcs_rg.name
  location            = azurerm_resource_group.adsvcs_rg.location
  #tags                = merge({ "ResourceName" = lower("nsg_${var.virtual_machine_name}_${data.azurerm_resource_group.rg.location}_in") }, var.tags, )
}

resource "azurerm_network_security_rule" "nsg_rule" {
  for_each                    = local.nsg_inbound_rules
  name                        = each.key
  priority                    = 100 * (each.value.idx + 1)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value.security_rule.destination_port_range
  source_address_prefix       = each.value.security_rule.source_address_prefix
  destination_address_prefix  = element(concat(data.azurerm_subnet.adsubnet.address_prefixes, [""]), 0)
  description                 = "Inbound_Port_${each.value.security_rule.destination_port_range}"
  resource_group_name         = azurerm_resource_group.adsvcs_rg.name
  network_security_group_name = azurerm_network_security_group.dc_nsg.name
  depends_on                  = [azurerm_network_security_group.dc_nsg]
}

resource "azurerm_network_interface_security_group_association" "nsgassoc" {
  count                     = var.instances_count
  network_interface_id      = element(concat(azurerm_network_interface.dc_nic.*.id, [""]), count.index)
  network_security_group_id = azurerm_network_security_group.dc_nsg.id
}

#---------------------------------------
# Windows Virutal machine
#---------------------------------------
resource "azurerm_windows_virtual_machine" "dc_vm" {
  count                      = var.instances_count
  name                       = var.instances_count == 1 ? var.virtual_machine_name : format("%s%s", lower(replace(var.virtual_machine_name, "/[[:^alnum:]]/", "")), count.index + 1)
  computer_name              = var.instances_count == 1 ? var.virtual_machine_name : format("%s%s", lower(replace(var.virtual_machine_name, "/[[:^alnum:]]/", "")), count.index + 1) # not more than 15 characters
  resource_group_name        = azurerm_resource_group.adsvcs_rg.name
  location                   = azurerm_resource_group.adsvcs_rg.location
  size                       = var.virtual_machine_size
  admin_username             = var.admin_username
  admin_password             = var.admin_password
  network_interface_ids      = [element(concat(azurerm_network_interface.dc_nic.*.id, [""]), count.index)]
  source_image_id            = var.source_image_id != null ? var.source_image_id : null
  provision_vm_agent         = true
  allow_extension_operations = true
  secure_boot_enabled = true
  vtpm_enabled = true
  license_type               = var.license_type
  patch_mode = "AutomaticByPlatform"
  availability_set_id        = var.enable_vm_availability_set == true ? element(concat(azurerm_availability_set.dc_aset.*.id, [""]), 0) : null
  #tags                       = merge({ "ResourceName" = var.instances_count == 1 ? var.virtual_machine_name : format("%s%s", lower(replace(var.virtual_machine_name, "/[[:^alnum:]]/", "")), count.index + 1) }, var.tags, )

  source_image_reference {
    publisher = var.dc_image_publisher
    offer     = var.dc_image_offer
    sku       = var.dc_image_sku
    version   = var.dc_image_version
  }

  os_disk {
    storage_account_type = var.os_disk_storage_account_type
    caching              = "ReadWrite"
  }

  identity {
    type = "SystemAssigned"
  }
}

#---------------------------------------
# Promote Domain Controller
#---------------------------------------
resource "azurerm_virtual_machine_extension" "adforest" {
  name                       = "ad-forest-creation"
  virtual_machine_id         = azurerm_windows_virtual_machine.dc_vm.0.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe -Command \"${local.powershell_command}\""
    }
SETTINGS
}


/*
#-------------------------------------
## Active Directory NSG for Clients 
#-------------------------------------

# Create the security group for AD Users
resource "azurerm_network_security_group" "active-directory-client-nsg" {
  name                = "${var.env}-ad-client-nsg"
  location            = azurerm_resource_group.adsvcs_rg.location
  resource_group_name = azurerm_resource_group.adsvcs_rg.name
}

#-------------------------------------
## Inbound Rules 
#-------------------------------------

# Port 53 DNS UDP
resource "azurerm_network_security_rule" "udp_53_client_inbound" {
  depends_on = [azurerm_resource_group.adsvcs_rg]

  count = length(local.dns_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "AD 53 DNS UDP - DC${count.index+1} Inbound"
  description                 = "AD 53 DNS UDP - DC${count.index+1} Inbound"
  priority                    = (150 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "53"
  source_address_prefix       = local.dns_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 88 Kerberos TCP
resource "azurerm_network_security_rule" "tcp_88_client_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "AD 88 Kerberos TCP - DC${count.index+1} Inbound"
  description                 = "AD 88 Kerberos TCP - DC${count.index+1} Inbound"
  priority                    = (160 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "88"
  source_address_prefix       = local.dns_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 135 RPC TCP
resource "azurerm_network_security_rule" "tcp_135_client_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "AD 135 RPC TCP - DC${count.index+1} Inbound"
  description                 = "AD 135 RPC TCP - DC${count.index+1} Inbound"
  priority                    = (170 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "135"
  source_address_prefix       = local.dns_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 389 LDAP TCP
resource "azurerm_network_security_rule" "tcp_389_client_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "AD 389 LDAP TCP - DC${count.index+1} Inbound"
  description                 = "AD 389 LDAP TCP - DC${count.index+1} Inbound"
  priority                    = (180 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "389"
  source_address_prefix       = local.dns_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 445 SMB TCP
resource "azurerm_network_security_rule" "tcp_445_client_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "AD 445 SMB TCP - DC${count.index+1} Inbound"
  description                 = "AD 445 SMB TCP - DC${count.index+1} Inbound"
  priority                    = (190 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "445"
  source_address_prefix       = local.dns_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 49152-65535 TCP
resource "azurerm_network_security_rule" "tcp_49152-65535_client_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "AD 49152-65535 TCP - DC${count.index+1} Inbound"
  description                 = "AD 49152-65535 TCP - DC${count.index+1} Inbound"
  priority                    = (200 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "49152-65535"
  source_address_prefix       = local.dns_servers[count.index]
  destination_address_prefix  = "*"
}

# Port 49152-65535 UDP
resource "azurerm_network_security_rule" "udp_49152-65535_client_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "AD 49152-65535 UDP - DC${count.index+1} Inbound"
  description                 = "AD 49152-65535 UDP - DC${count.index+1} Inbound"
  priority                    = (210 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "49152-65535"
  source_address_prefix       = local.dns_servers[count.index]
  destination_address_prefix  = "*"
}

# Allow ping AD Domain Controllers
resource "azurerm_network_security_rule" "icmp_client_inbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "AD Ping to DC${count.index+1} Inbound"
  description                 = "AD Ping to DC${count.index+1} Inbound"
  priority                    = (220 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Icmp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = local.dns_servers[count.index]
  destination_address_prefix  = "*"
}

#-------------------------------------
## Outbound Rules 
#-------------------------------------

# Port 53 DNS UDP
resource "azurerm_network_security_rule" "udp_53_client_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "AD 53 DNS UDP - DC${count.index+1} Outbound"
  description                 = "AD 53 DNS UDP - DC${count.index+1} Outbound"
  priority                    = (150 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "53"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_servers[count.index]
}

# Port 88 Kerberos TCP
resource "azurerm_network_security_rule" "tcp_88_client_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "AD 88 Kerberos TCP - DC${count.index+1} Outbound"
  description                 = "AD 88 Kerberos TCP - DC${count.index+1} Outbound"
  priority                    = (160 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "88"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_servers[count.index]
}

# Port 135 RPC TCP
resource "azurerm_network_security_rule" "tcp_135_client_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "AD 135 RPC TCP - DC${count.index+1} Outbound"
  description                 = "AD 135 RPC TCP - DC${count.index+1} Outbound"
  priority                    = (170 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "135"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_servers[count.index]
}

# Port 389 LDAP TCP
resource "azurerm_network_security_rule" "tcp_389_client_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "AD 389 LDAP TCP - DC${count.index+1} Outbound"
  description                 = "AD 389 LDAP TCP - DC${count.index+1} Outbound"
  priority                    = (180 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "389"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_servers[count.index]
}

# Port 445 SMB TCP
resource "azurerm_network_security_rule" "tcp_445_client_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "AD 445 SMB TCP - DC${count.index+1} Outbound"
  description                 = "AD 445 SMB TCP - DC${count.index+1} Outbound"
  priority                    = (190 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "445"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_servers[count.index]
}

# Port 49152-65535 TCP
resource "azurerm_network_security_rule" "tcp_49152-65535_client_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "AD 49152-65535 TCP - DC${count.index+1} Outbound"
  description                 = "AD 49152-65535 TCP - DC${count.index+1} Outbound"
  priority                    = (200 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "49152-65535"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_servers[count.index]
}

# Port 49152-65535 UDP
resource "azurerm_network_security_rule" "udp_49152-65535_client_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "AD 49152-65535 UDP - DC${count.index+1} Outbound"
  description                 = "AD 49152-65535 UDP - DC${count.index+1} Outbound"
  priority                    = (210 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "49152-65535"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_servers[count.index]
}

# Allow ping AD Domain Controllers
resource "azurerm_network_security_rule" "icmp_client_outbound" {
  depends_on = [azurerm_resource_group.network-rg]

  count = length(local.dns_servers)

  network_security_group_name = azurerm_network_security_group.active-directory-client-nsg.name
  resource_group_name         = azurerm_resource_group.network-rg.name
  name                        = "AD Ping to DC${count.index+1} Outbound"
  description                 = "AD Ping to DC${count.index+1} Outbound"
  priority                    = (220 + count.index)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Icmp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = local.dns_servers[count.index]
}
*/