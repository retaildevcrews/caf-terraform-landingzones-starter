data "azurerm_client_config" "current" {}

locals {
  azuread_groups_interface = {
    for key, azuread_group in var.azuread_groups : key => { 
        name        = azuread_group.name
        description = azuread_group.description
        members = {
            user_principal_names = []
            object_ids = [data.azurerm_client_config.current.object_id]
        }
        prevent_duplicate_name = azuread_group.prevent_duplicate_name
    }
  }
}