# Global variables
env                    = "dev"
location               = "eastus"

# Network Variables
avd_net_rg                = "avd-net-rg"
vnet_spoke_name           = "avd-spoke-vnet"
avd_subnet_name           = "avd-subnet"
ad_subnet_name            = "ad-subnet"
vnet_spoke_address_space  = ["10.0.48.0/20"]
ad_subnet_address_prefix  = ["10.0.49.0/24"]
avd_subnet_address_prefix = ["10.0.50.0/24"]
dns_servers               = ["168.63.129.16"]


# Storage Variables
avd_sa_rg                        = "avd-stor-rg"
profile_storage_account_name     = "profilestorage"
file_storage_account_name        = "commonstorage"
storage_min_tls_version          = "TLS1_2"
storage_account_tier             = "Premium"
storage_account_replication_type = "LRS"
fslogix_share_name               = "fslogix"
profiles_share_name              = "avdprofiles"
common_share_name                = "commonshare"


# AVD Compute Variables
avd_compute_rg                       = "avd-compute-rg"
avd_workspace                        = "avd_workspace"
avd_pool_name                        = "avd-pool"
avd_pool_friendly_name               = "AVD Host Pool"
avd_pool_loadbalancer                = "BreadthFirst"
avd_pool_custom_rdp_properties       = "audiocapturemode:i:1;audiomode:i:0;enablerdsaadauth:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;redirectclipboard:i:0;redirectprinters:i:0;redirectsmartcards:i:0;redirectwebauthn:i:0;"    #audiocapturemode:i:1;audiomode:i:0;targetisaadjoined:i:1;
avd_pool_max_session_limit           = 16
avd_pool_registation_expiration      = "36h"
avd_session_host_count               = 2
avd_session_host_name                = "avd-session-host"
avd_session_host_nic_name            = "avd-session-host-nic"
avd_session_host_vm_size             = "Standard_DC1s_v2"
avd_session_host_image_publisher     = "MicrosoftWindowsDesktop"
avd_session_host_image_offer         = "Windows-11"
avd_session_host_image_sku           = "win11-22h2-avd"
avd_session_host_os_profile_user     = "adminuser"
avd_session_host_os_profile_password = "Early-Autum_Flowers#"
domain_name                          = ""
ou_path                              = ""
domain_user_upn                      = ""
domain_password                      = ""

# RBAC
avd_aad_group_name                   = "VM-Access-Users"
vm_user_login_role_name              = "Virtual Machine User Login"
desktop_virtualization_role_name     = "Desktop Virtualization User"