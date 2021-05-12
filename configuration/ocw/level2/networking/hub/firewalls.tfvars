azurerm_firewalls = {
  fw_re1 = {  # egress firewall in hub network for region 1
    name               = "egress"
    resource_group_key = "vnet_hub_re1"
    vnet_key           = "hub_re1"
    # public_ip_key      = "firewall_re1" # if this is defined, public_ip_keys is ignored
    public_ip_keys      = ["firewall_re1","firewall_pip2_re1"]

    azurerm_firewall_network_rule_collections = [
    ]

    azurerm_firewall_application_rule_collections = [
    ]
  }

  # fw_re2 = {
  #   name               = "egress"
  #   resource_group_key = "vnet_hub_re2"
  #   vnet_key           = "hub_re2"
  #   # public_ip_key      = "firewall_re1" # if this is defined, public_ip_keys is ignored
  #   public_ip_keys      = ["firewall_re2","firewall_pip2_re2"]

  #   azurerm_firewall_network_rule_collections = [
  #   ]

  #   azurerm_firewall_application_rule_collections = [
  #   ]
  # }
}


