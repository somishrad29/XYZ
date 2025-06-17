resource "azurerm_virtual_network" "vnet" {
  name                = "alpha_vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.alpha.location
  resource_group_name = azurerm_resource_group.alpha.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "alpha_subnet1"
  resource_group_name  = azurerm_resource_group.alpha.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "alpha_nic"
  location            = azurerm_resource_group.alpha.location
  resource_group_name = azurerm_resource_group.alpha.name

  ip_configuration {
    name                          = "alpha_internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_public_ip" "public_ip" {
  name                = "AlphaPublicIP"
  location            = azurerm_resource_group.alpha.location
  resource_group_name = azurerm_resource_group.alpha.name
  allocation_method   = "Static"
  sku                 = "Basic"
}
output "vm_public_ip" {
  value = azurerm_public_ip.public_ip.ip_address
}



resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "alphavm1"
  location                        = azurerm_resource_group.alpha.location
  resource_group_name             = azurerm_resource_group.alpha.name
  network_interface_ids           = [azurerm_network_interface.nic.id]
  size                            = "Standard_D8s_v3"
  admin_username                  = "alphavm1"
  admin_password                  = "Admin@1234"
  disable_password_authentication = false

  os_disk {

    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}