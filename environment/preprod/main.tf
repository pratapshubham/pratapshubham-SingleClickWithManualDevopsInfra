module "resource_group" {
  source  = "../../modules/azure_resources_group"
  rgvalue = var.rgvalue
}

module "storage_account_value" {
  depends_on      = [module.resource_group]
  source          = "../../modules/azure_storage_account"
  storage_account = var.storage_account
}

module "virtual_network" {
  depends_on = [module.resource_group]
  source     = "../../modules/azure_virtual_network"
  vnet       = var.vnet
}

module "subnet" {
  depends_on = [module.virtual_network]
  source     = "../../modules/azure_subnet"
  subnet     = var.subnet
}

module "public_ip" {
  depends_on = [module.resource_group]
  source     = "../../modules/azure_public_ip"
  public_ip  = var.public_ip
}

module "network_security_group" {

  depends_on = [module.resource_group]
  source     = "../../modules/azure_network_security_group"
  nsg        = var.nsg

}

module "nsg_association" {

  depends_on      = [module.subnet, module.network_security_group]
  source          = "../../modules/azure_nsg_association"
  nsg_association = var.nsg_association
}

module "nic" {

  depends_on = [module.subnet, module.public_ip]
  source     = "../../modules/azure_nic"
  nic        = var.nic
}

module "virtual_machine" {

  depends_on = [module.nic]
  source     = "../../modules/azure_virtual_machine"
  vm         = var.vm
}