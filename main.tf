variable "virtual_network" {
    type = object({
    address_space = list(string)
    name = string

    })
  
}

variable "env"{
    type = string
    default = "project1"
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
    name = "${var.env}-nsg"
    location = azurerm_resource_group.myrg.location
    resource_group_name = azurerm_resource_group.myrg.name
    security_rule {
        name = "allow_ssh"
        priority = 100
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }
  
}
resource "azurerm_resource_group" "myrg" {

    name = "${var.env}-rg"
    location = "eastus"
}

provider "azurerm" {
    features {

    }
}
resource "azurerm_virtual_network" "vnet" {
    resource_group_name = azurerm_resource_group.myrg.name
    location = azurerm_resource_group.myrg.location
    name = "${var.env}-vnet"
    address_space = ["10.0.0.0/16"]
    subnet {
        name = "${var.env}-subnet1"
        address_prefix = "10.0.0.0/24"
        security_group = azurerm_network_security_group.nsg.id
    }


    }

  

