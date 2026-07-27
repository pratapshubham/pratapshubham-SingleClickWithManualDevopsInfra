module "resource_group" {
source = "../../modules/azure_resources_group"
rgvalue = var.rgvalue
}

module "virtual_network" {
    depends_on = [module.resource_group]
    source = "../../modules/azure_virtual_network"
    vnet = var.vnet
}

module "subnet" {
    depends_on = [module.virtual_network]
    source = "../../modules/azure_subnet"
    subnet = var.subnet
}

module "public_ip" {
  depends_on = [module.resource_group]
  source = "../../modules/azure_public_ip"
  public_ip = var.public_ip
}

module "network_security_group" {

  depends_on = [module.resource_group]
  source = "../../modules/azure_network_security_group"
  nsg = var.nsg

}