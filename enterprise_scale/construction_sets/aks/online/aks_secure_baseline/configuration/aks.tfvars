aks_clusters = {
  cluster_re1 = {
    name               = "akscluster"
    resource_group_key = "aks_re1"
    os_type            = "Linux"
    
    diagnostic_profiles = {
      operations = {
        name             = "aksoperations"
        definition_key   = "azure_kubernetes_cluster"
        destination_type = "log_analytics"
        destination_key  = "central_logs"
      }
    }

    identity = {
      type = "SystemAssigned"
    }

    kubernetes_version = "1.19.9"
    vnet_key           = "vnet_aks_re1"

    network_profile = {
      network_plugin    = "azure"
      load_balancer_sku = "Standard"
    }

    role_based_access_control = {
      enabled = true
      azure_active_directory = {
        managed = true
        admin_group_object_names = ["aks-cluster-admins"]
      }
    }

    outbound_type = "userDefinedRouting"

    addon_profile = {
      oms_agent = {
        enabled = true
        log_analytics_key = "central_logs_region1"
      }
      azure_policy = {
        enabled = true
      }
    }


    load_balancer_profile = {
      # Only one option can be set
      managed_outbound_ip_count = 1
      # outbound_ip_prefix_ids = []
      # outbound_ip_address_ids = []
    }

    default_node_pool = {
      name                  = "sharedsvc"
      vm_size               = "Standard_DS2_v2"
      subnet_key            = "aks_nodepool_system"
      enabled_auto_scaling  = false
      enable_node_public_ip = false
      max_pods              = 30
      node_count            = 3
      os_disk_type          = "Ephemeral"
      os_disk_size_gb       = 80
      orchestrator_version  = "1.19.9"
      availability_zones    = ["1", "2", "3"]
      tags = {
        "project" = "system services"
      }
    }

    node_resource_group_name = "aks-nodes"

    node_pools = {
      pool1 = {
        name                 = "npuser01"
        mode                 = "User"
        subnet_key           = "aks_nodepool_user1"
        max_pods             = 30
        vm_size              = "Standard_DS3_v2"
        node_count           = 3
        os_disk_type         = "Ephemeral"
        enable_auto_scaling  = false
        os_disk_size_gb      = 120
        orchestrator_version = "1.19.9"
        availability_zones   = ["1", "2", "3"]
        tags = {
          "project" = "user services"
        }
      }
    }

  }
}