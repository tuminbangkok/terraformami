#create resource_group
resource "azurerm_resource_group" "rg" {
  name     = "rg-example1-linux-terraform"
  location = "Southeast Asia"
  tags = {
    "Owner"   = "Attapol"
    "Project" = "Terraform"
    "Zone"    = "Test"
	  "File"  = "ex1_create_vm_user_pass"
  }
}

#create  vnet 
resource "azurerm_virtual_network" "examplevnet" {
  name                = "exampleVnet-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

#create  subnet
resource "azurerm_subnet" "examplesubnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.examplevnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

#create  public ip
resource "azurerm_public_ip" "examplepip" {
  name                = "examplepip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
}

#create  nic
resource "azurerm_network_interface" "example-nic" {
  name                = "example1-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.examplesubnet.id
    private_ip_address_allocation = "Dynamic"     #ถ้ากำหนดเป็น Static จะError
    public_ip_address_id          = azurerm_public_ip.examplepip.id   #***public ip Add manmual No auto***
  }
}

#create  nsg 
resource "azurerm_network_security_group" "example_nsg" {
  name                = "example_nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "Test_SSH"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "22"
    destination_address_prefix = azurerm_network_interface.example-nic.private_ip_address
  }
}

#create nsg association
resource "azurerm_network_interface_security_group_association" "example_nsg_association" {
  network_interface_id      = azurerm_network_interface.example-nic.id
  network_security_group_id = azurerm_network_security_group.example_nsg.id
}

#Create  vm
resource "azurerm_linux_virtual_machine" "example_vm" {
  name                = "examplevm-machine"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1ls"
  admin_username      = "testadmin"
  admin_password      = "P@sswprd1234!"
  disable_password_authentication = false
  network_interface_ids = [
      azurerm_network_interface.example-nic.id,
  ]

#create  Image
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

#create disk
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}