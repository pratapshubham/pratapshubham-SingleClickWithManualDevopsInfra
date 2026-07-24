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