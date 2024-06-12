variable "virtual_network" {
  type = object({
    address_space = list(string)


  })
  default = {
    address_space = ["10.0.0.0/16", ]
  }

}
variable "admin_username" {
  type      = string
  default   = "vijay"
  sensitive = true
}
variable "admin_password" {
  type      = string
  default   = "Hello@password"
  sensitive = true
}





variable "tag" {
  type = map(string)
  default = {
    "Name"        = "project1"
    "Environment" = "project1"
  }
}

variable "env" {
  type        = string
  default     = "project1"
  description = "Environment name"

}
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.27.0"
    }
  }
}
resource "azurerm_network_security_group" "nsg" {
  tags                = var.tag
  name                = "${var.env}-nsg"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
  security_rule {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}
resource "azurerm_resource_group" "myrg" {
  tags     = var.tag
  name     = "${var.env}-rg"
  location = "eastus"
}

provider "azurerm" {
  features {

  }
}
resource "azurerm_virtual_network" "vnet" {
  tags                = var.tag
  resource_group_name = azurerm_resource_group.myrg.name
  location            = azurerm_resource_group.myrg.location
  name                = "${var.env}-vnet"
  address_space       = var.virtual_network.address_space
}
resource "azurerm_subnet" "mysubnet" {
  resource_group_name  = azurerm_resource_group.myrg.name
  name                 = "${var.env}-subnet1"
  address_prefixes     = ["10.0.2.0/24"]
  virtual_network_name = azurerm_virtual_network.vnet.name


}



resource "azurerm_network_interface" "vmnic" {
  tags                = var.tag
  name                = "${var.env}-nic"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
  ip_configuration {
    name                          = "${var.env}-ipconfig"
    subnet_id                     = azurerm_subnet.mysubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vmip.id

  }
}

resource "azurerm_public_ip" "vmip" {
  tags                = var.tag
  name                = "${var.env}-ip"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
  allocation_method   = "Dynamic"
}



resource "azurerm_windows_virtual_machine" "myvm" {

  tags                  = var.tag
  resource_group_name   = azurerm_resource_group.myrg.name
  name                  = "${var.env}-vm"
  location              = azurerm_resource_group.myrg.location
  size                  = "Standard_B1ms"
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.vmnic.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}





