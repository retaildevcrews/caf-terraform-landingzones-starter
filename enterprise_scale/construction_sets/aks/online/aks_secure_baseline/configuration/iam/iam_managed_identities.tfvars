managed_identities = {
  ingress = {
    name               = "mi-ingress-controller"
    resource_group_key = "devops_re1"
  }
  apgw_keyvault_secrets = {
    name               = "mi-agw-secrets"
    resource_group_key = "devops_re1"
  }
}