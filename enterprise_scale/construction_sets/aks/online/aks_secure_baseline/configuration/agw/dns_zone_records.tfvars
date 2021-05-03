# Existing dns_zone in the target subscription
dns_zone_records = {

  record1 = {
    dns_zone = {
      name                = "<your domian name>" # e.g.    ngsa-pnp-dev.com
      resource_group_name = "<your domain's resource group name>"
    }

    records = {
    
      a = {
        agw = {
          name   = "<your alias>" # e.g.   test
        #   records = ["10.0.0.0"]
          resource_id = {
              public_ip_address = {
                   key = "agw_pip1_re1"
               }
          }
        }      
      }
    }   //record2
  }
}