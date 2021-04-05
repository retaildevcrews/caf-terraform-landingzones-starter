locals {
  resource_groups_interface = {
    for key, resource_group in var.resource_groups : key => { 
      key    = key
      name   = "${resource_group.name}-${var.local_settings.project}-${var.local_settings.env}"
      region = resource_group.region
    }
  }

  aks_clusters_interface = {
    for key, cluster in var.aks_clusters : key => {
      key                       = key
      name                      = "${cluster.name}-${var.local_settings.project}-${var.local_settings.env}"
      resource_group_key        = cluster.resource_group_key
      os_type                   = cluster.os_type
      diagnostic_profiles       = cluster.diagnostic_profiles
      identity                  = cluster.identity
      kubernetes_version        = cluster.kubernetes_version
      vnet_key                  = cluster.vnet_key
      network_profile           = cluster.network_profile
      role_based_access_control = cluster.role_based_access_control
      outbound_type             = cluster.outbound_type
      addon_profile             = cluster.addon_profile
      load_balancer_profile     = cluster.load_balancer_profile
      default_node_pool         = cluster.default_node_pool
      node_resource_group_name  = "${cluster.node_resource_group_name}-${var.local_settings.project}-${var.local_settings.env}"
      node_pools                = cluster.node_pools
    }
  }

  managed_identities_interface = {
    for key, mi in var.managed_identities : key => {
      key                = key
      name               = "${mi.name}-${var.local_settings.project}-${var.local_settings.env}"
      resource_group_key = mi.resource_group_key
    }
  }

  keyvaults_interface = {
    for key, keyvault in var.keyvaults : key => {
      key                 = key
      name                = "${keyvault.name}-${var.local_settings.project}-${var.local_settings.env}"
      resource_group_key  = keyvault.resource_group_key
      region              = keyvault.region
      sku_name            = keyvault.sku_name
      soft_delete_enabled = keyvault.soft_delete_enabled
      creation_policies   = keyvault.creation_policies
    }
  }

  application_gateways_interface = {
    for key, gateway in var.application_gateways : key => {
      key                         = key
      resource_group_key          = gateway.resource_group_key
      name                        = "${gateway.name}-${var.local_settings.project}-${var.local_settings.env}"
      vnet_key                    = gateway.vnet_key
      subnet_key                  = gateway.subnet_key
      sku_name                    = gateway.sku_name
      sku_tier                    = gateway.sku_tier
      capacity                    = gateway.capacity
      zones                       = gateway.zones
      enable_http2                = gateway.enable_http2
      identity                    = gateway.identity
      front_end_ip_configurations = gateway.front_end_ip_configurations
      front_end_ports             = gateway.front_end_ports
      trusted_root_certificate    = gateway.trusted_root_certificate
    }
  }

}

