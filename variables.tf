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

# private endpoints
variable "private_dns_zone_blob" {   
    type        = string
    description = "MS predefined private dns zone name for blob storage"
}

variable "private_dns_zone_file" {   
    type        = string
    description = "MS predefined private dns zone id for file storage"
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

variable "profile_storage_account_name" {
    type        = string
    description = "fslogix file storage account"
}

variable "fslogix_storage_account_name" {
    type        = string
    description = "fslogix file storage account"
}

variable "file_storage_account_name" {
    type        = string
    description = "profile storage account"
}

variable "golden_images_storage_account_name" {
    type        = string
    description = "golden images storage account"
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

#------------------------
# AVD COMPUTE COMPONENTS
#------------------------
variable "avd_compute_rg" {
    type        = string
    description = "resource group where all avd host and hostpool infra will be stored"
}

# AVD Pool parameters
# Prod Pool
variable "avd_autoscale_role" {
    type        = string
    description = "AVD autoscale role name"
}

variable "avd_autoscale_role_desc" {
    type        = string
    description = "AVD autoscale role description"
}

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

# autoscaling plan variables
variable "avd_scaling_plan_name" {
    type        = string
    description = "AVD scaling plan name"
}

variable "avd_scaling_plan_friendlyname" {
    type        = string
    description = "AVD scaling plan friendly name"
}

variable "avd_scaling_plan_timezone" {
    type        = string
    description = "AVD scaling plan timezone"
}

# scaling plan weekday schedule
variable "avd_scaling_plan_weekday_name" {
    type        = string
    description = "AVD scaling plan weekday name"
}

variable "avd_scaling_plan_weekday_days" {
    type        = list(string)
    description = "AVD scaling plan weekday applicable days"
}

variable "avd_scaling_plan_weekday_ramp_up_start_time" {
    type        = string
    description = "AVD scaling plan weekday ramp up start time"
}

variable "avd_scaling_plan_weekday_ramp_up_lb_algo" {
    type        = string
    description = "AVD scaling plan weekday ramp up LB algorythm"
}

variable "avd_scaling_plan_weekday_ramp_up_minimum_host_pct" {
    type        = number
    description = "AVD scaling plan weekday ramup up minimum hosts percent"
}

variable "avd_scaling_plan_weekday_ramp_up_capacity_threshold_pct" {
    type        = number
    description = "AVD scaling plan weekday ramup up capacity threshold percent"
}

variable "avd_scaling_plan_weekday_ramp_up_peak_time" {
    type        = string
    description = "AVD scaling plan weekday ramp up peak start time"
}

variable "avd_scaling_plan_weekday_ramp_up_peak_lb_algo" {
    type        = string
    description = "AVD scaling plan weekday ramp up peak LB algorithm"
}

variable "avd_scaling_plan_weekday_ramp_down_start_time" {
    type        = string
    description = "AVD scaling plan weekday ramp DOWN start time"
}

variable "avd_scaling_plan_weekday_ramp_down_lb_algo" {
    type        = string
    description = "AVD scaling plan weekday ramp DOWN LB algorithm"
}

variable "avd_scaling_plan_weekday_ramp_down_minimum_host_pct" {
    type        = number
    description = "AVD scaling plan weekday ramp DOWN minimum hosts percent"
}

variable "avd_scaling_plan_weekday_ramp_down_force_logoff" {
    type        = bool
    description = "AVD scaling plan weekday ramp DOWN force logoff users"
}

variable "avd_scaling_plan_weekday_ramp_down_wait_time" {
    type        = number
    description = "AVD scaling plan weekday ramp DOWN wait time minutes"
}

variable "avd_scaling_plan_weekday_ramp_down_notification_msg" {
    type        = string
    description = "AVD scaling plan weekday ramp DOWN notification message"
}

variable "avd_scaling_plan_weekday_ramp_down_capacity_threshold_pct" {
    type        = number
    description = "AVD scaling plan weekday ramp DOWN capacity threshold percent"
}

variable "avd_scaling_plan_weekday_ramp_down_stop_hosts_when" {
    type        = string
    description = "AVD scaling plan weekday ramp DOWN stop hosts when"
}

variable "avd_scaling_plan_weekday_off_peak_start_time" {
    type        = string
    description = "AVD scaling plan weekday off peak start time"
}

variable "avd_scaling_plan_weekday_off_lb_algo" {
    type        = string
    description = "AVD scaling plan weekday off peak LB algorithm"
}

# scaling plan weekend schedule
variable "avd_scaling_plan_weekend_name" {
    type        = string
    description = "AVD scaling plan weekend name"
}

variable "avd_scaling_plan_weekend_days" {
    type        = list(string)
    description = "AVD scaling plan weekend applicable days"
}

variable "avd_scaling_plan_weekend_ramp_up_start_time" {
    type        = string
    description = "AVD scaling plan weekend ramp up start time"
}

variable "avd_scaling_plan_weekend_ramp_up_lb_algo" {
    type        = string
    description = "AVD scaling plan weekend ramp up LB algorythm"
}

variable "avd_scaling_plan_weekend_ramp_up_minimum_host_pct" {
    type        = number
    description = "AVD scaling plan weekend ramup up minimum hosts percent"
}

variable "avd_scaling_plan_weekend_ramp_up_capacity_threshold_pct" {
    type        = number
    description = "AVD scaling plan weekend ramup up capacity threshold percent"
}

variable "avd_scaling_plan_weekend_ramp_up_peak_time" {
    type        = string
    description = "AVD scaling plan weekend ramp up peak start time"
}

variable "avd_scaling_plan_weekend_ramp_up_peak_lb_algo" {
    type        = string
    description = "AVD scaling plan weekend ramp up peak LB algorithm"
}

variable "avd_scaling_plan_weekend_ramp_down_start_time" {
    type        = string
    description = "AVD scaling plan weekend ramp DOWN start time"
}

variable "avd_scaling_plan_weekend_ramp_down_lb_algo" {
    type        = string
    description = "AVD scaling plan weekend ramp DOWN LB algorithm"
}

variable "avd_scaling_plan_weekend_ramp_down_minimum_host_pct" {
    type        = number
    description = "AVD scaling plan weekend ramp DOWN minimum hosts percent"
}

variable "avd_scaling_plan_weekend_ramp_down_force_logoff" {
    type        = bool
    description = "AVD scaling plan weekend ramp DOWN force logoff users"
}

variable "avd_scaling_plan_weekend_ramp_down_wait_time" {
    type        = number
    description = "AVD scaling plan weekend ramp DOWN wait time minutes"
}

variable "avd_scaling_plan_weekend_ramp_down_notification_msg" {
    type        = string
    description = "AVD scaling plan weekend ramp DOWN notification message"
}

variable "avd_scaling_plan_weekend_ramp_down_capacity_threshold_pct" {
    type        = number
    description = "AVD scaling plan weekend ramp DOWN capacity threshold percent"
}

variable "avd_scaling_plan_weekend_ramp_down_stop_hosts_when" {
    type        = string
    description = "AVD scaling plan weekend ramp DOWN stop hosts when"
}

variable "avd_scaling_plan_weekend_off_peak_start_time" {
    type        = string
    description = "AVD scaling plan weekend off peak start time"
}

variable "avd_scaling_plan_weekend_off_lb_algo" {
    type        = string
    description = "AVD scaling plan weekend off peak LB algorithm"
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


# RBAC
variable "vm_user_login_role_name" {
    type        = string
    description = "Azure role for virtual machine user login"
}

variable "desktop_virtualization_role_name" {
    type        = string
    description = "Azure role for virtual machine user login"
}

variable "avd_aad_group_name" {
      type        = string
      description = "Entra ID Group to allow access to AVD"
}

variable "remote_app_group_entitlement" {
      type        = string
      description = "Entra ID Group to entitle to remote app group (RAG)"
}

variable "desktop_app_group_entitlement" {
      type        = string
      description = "Entra ID Group to entitle to desktop app group (DAG)"
}