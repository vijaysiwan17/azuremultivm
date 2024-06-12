variable "virtual_network" {
  type = object({
    address_space = list(string)


  })
  default = {
    address_space = ["10.0.0.0/16",]
  }

}
variable "tag" {
type = map(string) 
  default = {
    "Name" = "project1"
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
    tags = var.tag
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
tags = var.tag
  name     = "${var.env}-rg"
  location = "eastus"
}

provider "azurerm" {
  features {

  }
}
resource "azurerm_virtual_network" "vnet" {
    tags = var.tag
  resource_group_name = azurerm_resource_group.myrg.name
  location            = azurerm_resource_group.myrg.location
  name                = "${var.env}-vnet"
  address_space       = var.virtual_network.address_space
  subnet {
    name           = "${var.env}-subnet1"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg.id
  }


}



