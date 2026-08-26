data "azurerm_subnet" "subnet" {

  for_each = var.shubham_bastion

  name                 = each.value.subnet_name
  virtual_network_name = each.value.virtual_network_name
  resource_group_name  = each.value.resource_group_name
}


data "azurerm_public_ip" "pip" {
  for_each = {
    for k, v in var.shubham_bastion : k => v if v.public_ip_name != ""
  }

  name                = each.value.public_ip_name
  resource_group_name = each.value.resource_group_name
}


resource "azurerm_bastion_host" "bastion" {
  for_each = var.shubham_bastion

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name


  ip_configuration {
    name                 = "internal"
    subnet_id            = data.azurerm_subnet.subnet[each.key].id
    public_ip_address_id = data.azurerm_public_ip.pip[each.key].id
  }
}