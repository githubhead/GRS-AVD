#-------------------
# GLOBAL VARS
#-------------------
env                    = "uat"
location               = "eastus"

#----------------
# NETWORK BACKEND
#----------------
avd_net_rg                = "avd-net-rg"
vnet_spoke_name           = "avd-spoke-vnet"
avd_subnet_name           = "avd-subnet"
ad_subnet_name            = "ad-subnet"
vnet_spoke_address_space  = ["10.0.80.0/20"]
ad_subnet_address_prefix  = ["10.0.81.0/24"]
avd_subnet_address_prefix = ["10.0.82.0/24"]
dns_servers               = ["168.63.129.16"]

# private endpoints
private_dns_zone_blob              = "privatelink.blob.core.windows.net"  #do NOT change
private_dns_zone_file              = "privatelink.file.core.windows.net"  #do NOT change

#----------------
# STORAGE BACKEND
#----------------
avd_sa_rg                          = "avd-stor-rg"
profile_storage_account_name       = "profilestorage"
file_storage_account_name          = "commonstorage"
fslogix_storage_account_name       = "fslogixprofiles"
golden_images_storage_account_name = "goldenimages"
storage_min_tls_version            = "TLS1_2"
storage_account_tier               = "Premium"
storage_account_replication_type   = "LRS"
fslogix_share_name                 = "fslogix"
profiles_share_name                = "avdprofiles"
common_share_name                  = "commonshare"


# Storage RBAC
# roles
fs_admin_role  = "Storage File Data SMB Share Elevated Contributor"
fs_rw_role     = "Storage File Data SMB Share Contributor"
fs_ro_role     = "Storage File Data SMB Share Reader"

# groups
fs_fslogix_admin_group = "FS-FSLogix-Admin"
fs_fslogix_rw_group    = "FS-FSLogix-RW"
fs_profiles_admin_group = "FS-ProfileShare-Admin"
fs_profiles_rw_group    = "FS-ProfileShare-RW"
fs_common_admin_group   = "FS-Common-Admin"
fs_common_rw_group      = "FS-Common-RW"
fs_common_ro_group      = "FS-Common-RO"

#----------------------
# AVD COMPUTE VARIABLES
#----------------------
avd_compute_rg                       = "avd-compute-rg"
avd_autoscale_role                   = "avd-autoscale-role"
avd_autoscale_role_desc              = "AVD Autoscale Custom Role"
avd_workspace                        = "avd_workspace"
avd_pool_name                        = "avd-pool"
avd_pool_friendly_name               = "AVD Host Pool"
avd_pool_loadbalancer                = "BreadthFirst"
avd_pool_custom_rdp_properties       = "audiocapturemode:i:0;audiomode:i:0;enablerdsaadauth:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;redirectclipboard:i:0;redirectprinters:i:0;redirectsmartcards:i:0;redirectwebauthn:i:0;"    #audiocapturemode:i:1;audiomode:i:0;targetisaadjoined:i:1;
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

# scaling plan variables
avd_scaling_plan_name                                     = "avd-scaling-plan"
avd_scaling_plan_friendlyname                             = "Week and weekend AVD scaling plan"
avd_scaling_plan_timezone                                 = "Eastern Standard Time"
# scaling plan weekday schedule
avd_scaling_plan_weekday_name                             = "Weekday"
avd_scaling_plan_weekday_days                             = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
avd_scaling_plan_weekday_ramp_up_start_time               = "07:00"
avd_scaling_plan_weekday_ramp_up_lb_algo                  = "BreadthFirst"
# min % of session host to start during ramp-up for peak hours. If value is 10% and host pool is configured with 10 hosts, a minimum of 1 session host is available to take user connections.
avd_scaling_plan_weekday_ramp_up_minimum_host_pct         = 30
# % of used ttl host pool capacity to turn on/off hosts during rump up/peak hrs. If ttl host pool capacity is 100 sessions and this value is set to 60, new hosts will be turned on when sessions reach 60
avd_scaling_plan_weekday_ramp_up_capacity_threshold_pct   = 80
avd_scaling_plan_weekday_ramp_up_peak_time                = "09:00"
avd_scaling_plan_weekday_ramp_up_peak_lb_algo             = "DepthFirst"
avd_scaling_plan_weekday_ramp_down_start_time             = "16:00"
avd_scaling_plan_weekday_ramp_down_lb_algo                = "BreadthFirst"
# min % of session hosts that we'd like to get to for ramp-down and off-peak hours. If this value is set to 10% and ttl hosts is 10, autoscale will aim to wind down to 1 host
avd_scaling_plan_weekday_ramp_down_minimum_host_pct       = 20
avd_scaling_plan_weekday_ramp_down_force_logoff           = false
avd_scaling_plan_weekday_ramp_down_wait_time              = 30
avd_scaling_plan_weekday_ramp_down_notification_msg       = "Your session will end in 30mins."
# % of used ttl host pool capacity to turn on/off hosts during ramp down/off-peak. If ttl host pool capacity is 100 sessions and this value is set to 60, new hosts will be turned on ONLY if sessions are above this threshold. Otherwise, they'll be turned off
avd_scaling_plan_weekday_ramp_down_capacity_threshold_pct = 50
avd_scaling_plan_weekday_ramp_down_stop_hosts_when        = "ZeroActiveSessions"
avd_scaling_plan_weekday_off_peak_start_time              = "19:00"
avd_scaling_plan_weekday_off_lb_algo                      = "BreadthFirst"
# scaling plan weekend schedule
avd_scaling_plan_weekend_name                             = "Weekend"
avd_scaling_plan_weekend_days                             = ["Saturday", "Sunday"]
avd_scaling_plan_weekend_ramp_up_start_time               = "08:00"
avd_scaling_plan_weekend_ramp_up_lb_algo                  = "BreadthFirst"
avd_scaling_plan_weekend_ramp_up_minimum_host_pct         = 10
avd_scaling_plan_weekend_ramp_up_capacity_threshold_pct   = 80
avd_scaling_plan_weekend_ramp_up_peak_time                = "09:00"
avd_scaling_plan_weekend_ramp_up_peak_lb_algo             = "DepthFirst"
avd_scaling_plan_weekend_ramp_down_start_time             = "14:00"
avd_scaling_plan_weekend_ramp_down_lb_algo                = "BreadthFirst"
avd_scaling_plan_weekend_ramp_down_minimum_host_pct       = 20
avd_scaling_plan_weekend_ramp_down_force_logoff           = false
avd_scaling_plan_weekend_ramp_down_wait_time              = 30
avd_scaling_plan_weekend_ramp_down_notification_msg       = "Your session will end in 30mins."
avd_scaling_plan_weekend_ramp_down_capacity_threshold_pct = 50
avd_scaling_plan_weekend_ramp_down_stop_hosts_when        = "ZeroActiveSessions"
avd_scaling_plan_weekend_off_peak_start_time              = "16:00"
avd_scaling_plan_weekend_off_lb_algo                      = "BreadthFirst"

# AVD RBAC
# roles
vm_user_login_role_name              = "Virtual Machine User Login"     #Role for vm user login rights
desktop_virtualization_role_name     = "Desktop Virtualization User"
# groups
avd_aad_group_name                   = "VM-Access-Users"                #Group to entitle log in into hosts
remote_app_group_entitlement         = "AVD-Remote_Apps_Group"
desktop_app_group_entitlement        = "AVD-Desktop_App_Group"