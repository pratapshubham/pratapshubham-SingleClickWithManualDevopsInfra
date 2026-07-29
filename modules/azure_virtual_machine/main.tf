data "azurerm_network_interface" "nic" {

  for_each = var.vm
  name                = each.value.nic_name
  resource_group_name = each.value.resource_group_name
}

resource "azurerm_linux_virtual_machine" "vm" {

  for_each = var.vm

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  size                            = each.value.size
  admin_username                  = each.value.admin_username
  disable_password_authentication = false
  admin_password                  = each.value.admin_password

  network_interface_ids = [data.azurerm_network_interface.nic[each.key].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
  publisher = "Canonical"
  offer     = "ubuntu-24_04-lts"
  sku        = "server"
  version    = "latest"
  }

  computer_name = each.value.name
}