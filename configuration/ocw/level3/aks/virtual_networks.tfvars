vnets = {
  spoke_aks_re1 = {
    resource_group_key = "aks_spoke_re1"
    region             = "region1"
    vnet = {
      name          = "aks"
      address_space = ["100.64.48.0/22"]
    }
    specialsubnets = {}
    subnets = {
      aks_nodepool_system = {
        name    = "aks_nodepool_system"
        cidr    = ["100.64.48.0/24"]
        nsg_key = "azure_kubernetes_cluster_nsg"
        route_table_key = "default_to_firewall_re1"        
      }
      aks_nodepool_apps1 = {
        name    = "aks_nodepool_apps1"
        cidr    = ["100.64.49.0/24"]
        nsg_key = "azure_kubernetes_cluster_nsg"
        route_table_key = "default_to_firewall_re1"
      }
      aks_nodepool_apps2 = {
        name    = "aks_nodepool_apps2"
        cidr    = ["100.64.50.0/24"]
        nsg_key = "azure_kubernetes_cluster_nsg"
        route_table_key = "default_to_firewall_re1"
      }
      # AzureBastionSubnet = {
      #   name    = "AzureBastionSubnet" #Must be called AzureBastionSubnet
      #   cidr    = ["100.64.51.64/27"]
      #   nsg_key = "azure_bastion_nsg"
      # }
      private_endpoints = {
        name                                           = "private_endpoints"
        cidr                                           = ["100.64.51.0/27"]
        enforce_private_link_endpoint_network_policies = true
        nsg_key                                        = "empty_nsg"
      }
      # jumpbox = {
      #   name    = "jumpbox"
      #   cidr    = ["100.64.51.32/28"] 
      #   nsg_key = "azure_bastion_nsg"
      # }
      application_gateway = {
        name    = "agw"
        cidr    = ["100.64.51.128/27"] 
        nsg_key = "application_gateway"
      }      
    }

  }
}
