resource "azurerm_virtual_machine" "linux_vm" {
  name = "my-simple-vm"
  location = "West Europe"
  resource_group_name = "my-resource-group"

  vm_size = "Standard_B1s"

  storage_os_disk {
    name = "my-os-disk"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
    image = {
      publisher = "Canonical"
      offer = "Ubuntu Server"
      sku = "18.04-LTS"
      version = "latest"
    }
  }

  network_interface_ids = [azurerm_network_interface.main.id]
}

resource "azurerm_network_interface" "main" {
  name = "my-vm-nic"
  location = azurerm_virtual_machine.linux_vm.location
  resource_group_name = azurerm_virtual_machine.linux_vm.resource_group_name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [azurerm_subnet.internal]
}

resource "azurerm_subnet" "internal" {
  name = "internal-subnet"
  resource_group_name = azurerm_virtual_machine.linux_vm.resource_group_name
  address_prefixes = ["10.0.1.0/24"]
  virtual_network_name = azurerm_virtual_network.main.name

  depends_on = [azurerm_virtual_network.main]
}

resource "azurerm_virtual_network" "main" {
  name = "my-vnet"
  location = azurerm_virtual_machine.linux_vm.location
  address_space = ["10.0.0.0/16"]
}
