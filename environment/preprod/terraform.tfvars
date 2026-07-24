rgvalue = {
  rg1 = {
    name     = "shubham-rg"
    location = "eastus"
  }

  rg2 = {
    name     = "deepak-rg"
    location = "centralindia"
  }
}

vnet = {
  vnet1 = {
    name                = "shubham-vnet"
    resource_group_name = "shubham-rg"
    location            = "eastus"
    address_space       = ["10.1.0.0/24"]
  }
}

subnet = {
  snet1 = {
    name                 = "shubham-subnet"
    resource_group_name  = "shubham-rg"
    virtual_network_name = "shubham-vnet"
    address_prefixes     = ["10.1.0.128/25"]
  }
}
