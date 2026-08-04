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

storage_account = {

  storage_account1 = {
    name                     = "shubhamstorage0108"
    resource_group_name      = "shubham-rg"
    location                 = "eastus"
    account_tier             = "Standard"
    account_replication_type = "LRS"
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
    name                 = "shubham-subnet-frontend"
    resource_group_name  = "shubham-rg"
    virtual_network_name = "shubham-vnet"
    address_prefixes     = ["10.1.0.0/25"]
  }

  snet2 = {
    name                 = "shubham-subnet-backend"
    resource_group_name  = "shubham-rg"
    virtual_network_name = "shubham-vnet"
    address_prefixes     = ["10.1.0.128/25"]
  }

  snet3 = {
    name                 = "queuebuster-subnet"
    resource_group_name  = "queuebuster-rg"
    virtual_network_name = "queuebuster-vnet"
    address_prefixes     = ["10.1.0.0/24"]
  }
}

public_ip = {

  frontend = {
    name                = "frontend-pip"
    location            = "eastus"
    resource_group_name = "shubham-rg"
    allocation_method   = "Static"
    sku                 = "Standard"
  }

}

nsg = {

  frontend = {
    name                = "frontend-nsg"
    location            = "eastus"
    resource_group_name = "shubham-rg"

  }

  backend = {
    name                = "backend-nsg"
    location            = "eastus"
    resource_group_name = "shubham-rg"

  }

}

nsg_association = {

  frontend = {

    subnet_name          = "shubham-subnet-frontend"
    virtual_network_name = "shubham-vnet"
    resource_group_name  = "shubham-rg"
    nsg_name             = "frontend-nsg"

  }

  backend = {

    subnet_name          = "shubham-subnet-backend"
    virtual_network_name = "shubham-vnet"
    resource_group_name  = "shubham-rg"
    nsg_name             = "backend-nsg"

  }

}

nic = {

  frontend = {

    name                 = "frontend-nic"
    location             = "eastus"
    resource_group_name  = "shubham-rg"
    subnet_name          = "shubham-subnet-frontend"
    virtual_network_name = "shubham-vnet"
    public_ip_name       = "frontend-pip"

  }

  backend = {

    name                 = "backend-nic"
    location             = "eastus"
    resource_group_name  = "shubham-rg"
    subnet_name          = "shubham-subnet-backend"
    virtual_network_name = "shubham-vnet"
    public_ip_name       = ""

  }

}

vm = {

  frontend = {

    name                = "frontend-vm"
    location            = "eastus"
    resource_group_name = "shubham-rg"
    size                = "Standard_D2s_v3"
    admin_username      = "azureuser"
    admin_password      = "Password@123456"
    nic_name            = "frontend-nic"
  }

  backend = {

    name                = "backend-vm"
    location            = "eastus"
    resource_group_name = "shubham-rg"
    size                = "Standard_D2s_v3"
    admin_username      = "azureuser"
    admin_password      = "Password@123456"
    nic_name            = "backend-nic"
  }
}
