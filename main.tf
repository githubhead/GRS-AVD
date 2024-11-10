

# Create AVD spoke network resources
module "avd_network" {
    source                    = "./modules/network_backend"
    location                  = var.location
    env                       = var.env
    avd_net_rg                = var.avd_net_rg
    vnet_spoke_name           = var.vnet_spoke_name
    vnet_spoke_address_space  = var.vnet_spoke_address_space
    avd_subnet_name           = var.avd_subnet_name
    ad_subnet_name            = var.ad_subnet_name
    ad_subnet_address_prefix  = var.ad_subnet_address_prefix
    avd_subnet_address_prefix = var.avd_subnet_address_prefix
    dns_servers               = var.dns_servers
}

# Create AVD Storage resources
module "avd_storage" {
    source                           = "./modules/storage_backend"
    location                         = var.location
    env                              = var.env
    avd_sa_rg                        = var.avd_sa_rg
    profile_storage_account_name     = var.profile_storage_account_name
    storage_min_tls_version          = var.storage_min_tls_version
    storage_account_tier             = var.storage_account_tier
    storage_account_replication_type = var.storage_account_replication_type
    fslogix_share_name               = var.fslogix_share_name
    profiles_share_name              = var.profiles_share_name
    file_storage_account_name        = var.file_storage_account_name
    common_share_name                = var.common_share_name
}

# Create AVD Compute resources
module "avd_compute" {
    source                               = "./modules/avd_compute"
    location                             = var.location
    env                                  = var.env
    avd_compute_rg                       = var.avd_compute_rg
    avd_net_rg                           = "${var.env}-${var.avd_net_rg}"
    avd_subnet_name                      = "${var.env}-${var.avd_subnet_name}"
    vnet_spoke_name                      = "${var.env}-${var.vnet_spoke_name}"
    avd_workspace                        = var.avd_workspace
    avd_pool_name                        = var.avd_pool_name
    avd_pool_friendly_name               = var.avd_pool_friendly_name
    avd_pool_loadbalancer                = var.avd_pool_loadbalancer
    avd_pool_custom_rdp_properties       = var.avd_pool_custom_rdp_properties
    avd_pool_max_session_limit           = var.avd_pool_max_session_limit
    avd_session_host_count               = var.avd_session_host_count
    avd_pool_registation_expiration      = var.avd_pool_registation_expiration
    avd_session_host_name                = var.avd_session_host_count
    avd_session_host_nic_name            = var.avd_session_host_nic_name
    avd_session_host_vm_size             = var.avd_session_host_vm_size
    avd_session_host_image_publisher     = var.avd_session_host_image_publisher
    avd_session_host_image_offer         = var.avd_session_host_image_offer
    avd_session_host_image_sku           = var.avd_session_host_image_sku
    avd_session_host_os_profile_user     = var.avd_session_host_os_profile_user
    avd_session_host_os_profile_password = var.avd_session_host_os_profile_password
    domain_name                          = var.domain_name
    ou_path                              = var.ou_path
    domain_user_upn                      = var.domain_user_upn
    domain_password                      = var.domain_password
    avd_aad_group_name                   = var.avd_aad_group_name
    vm_user_login_role_name              = var.vm_user_login_role_name
    desktop_virtualization_role_name     = var.desktop_virtualization_role_name
    depends_on = [ module.avd_network ]
}