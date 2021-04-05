global_settings = {
  passthrough    = false
  random_length  = 0
  prefix         = "ngsa-pnp-dev" # Adjust prefix by passing unique combination of these values: (project-short-form)-(team-name)-(environment)
  default_region = "region1"
  regions        = {
    region1 = "eastus2"           # You can adjust the Azure Region you want to use to deploy AKS and the related services
  # region2 = "eastus"            # Optional - Add additional regions
  }
}