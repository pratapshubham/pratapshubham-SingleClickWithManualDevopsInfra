data "azurerm_subnet" "subnet" {

  for_each = var.nic

  name                 = each.value.subnet_name
  virtual_network_name = each.value.virtual_network_name
  resource_group_name  = each.value.resource_group_name
}

data "azurerm_public_ip" "pip" {

  for_each = {
    for k, v in var.nic : k => v if v.public_ip_name != ""
  }

  name                = each.value.public_ip_name
  resource_group_name = each.value.resource_group_name
}

resource "azurerm_network_interface" "nic" {

  for_each = var.nic

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  ip_configuration {

    name = "internal"

    subnet_id = data.azurerm_subnet.subnet[each.key].id

    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = lookup(
      data.azurerm_public_ip.pip,
      each.key,
      null
    ) != null ? data.azurerm_public_ip.pip[each.key].id : null
  }
}