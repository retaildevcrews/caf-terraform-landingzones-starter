landingzone = {
  backend_type        = "azurerm"
  level               = "level3"
  key                 = "cluster_aks"
  global_settings_key = "shared_services"
  tfstates = {
    launchpad = {
      level   = "lower"
      tfstate = "caf_launchpad.tfstate"
    }   
    shared_services = {
      level   = "lower"
      tfstate = "caf_shared_services.tfstate"
    }
    networking_hub = {
      level   = "lower"
      tfstate = "networking_hub.tfstate"
    }
 
  }
}

