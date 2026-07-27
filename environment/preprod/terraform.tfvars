rgvalue = {
  rg1 = {
    name     = "shubham-rg"
    location = "eastus"
  }

  rg2 = {
    name     = "deepak-rg"
    location = "centralindia"
  }

   rg3 = {
    name     = "queuebuster-rg"
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

  vnet2 = {
    name                = "queuebuster-vnet"
    resource_group_name = "queuebuster-rg"
    location            = "centralindia"
    address_space       = ["10.1.0.0/16"]
  }
  
}

subnet = {
  snet1 = {
    name                 = "shubham-subnet"
    resource_group_name  = "shubham-rg"
    virtual_network_name = "shubham-vnet"
    address_prefixes = ["10.1.0.0/25"]
  }

    snet2 = {
    name                 = "shubham-subnet2"
    resource_group_name  = "shubham-rg"
    virtual_network_name = "shubham-vnet"
    address_prefixes = ["10.1.0.128/25"]
  }

   snet3 = {
    name                 = "queuebuster-subnet"
    resource_group_name  = "queuebuster-rg"
    virtual_network_name = "queuebuster-vnet"
    address_prefixes = ["10.1.0.0/24"]
  }
}
