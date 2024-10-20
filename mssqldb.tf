
# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

#Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "class"
  location = "eastus2"
  
  tags = {
    Environment = "Terraform Getting Started"
    Team = "DevOps"
  }
}


# Create virtual network
resource "azurerm_virtual_network" "example" {
  name                = "vnat1"
  address_space       = ["172.16.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}


# Create subnet within the virtual network
resource "azurerm_subnet" "example" {
  name                 = "Subnet1"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["172.16.10.0/24"]
}


#Create DataBase
resource "azurerm_mssql_managed_instance" "example" {
  name                = "mydbserver1"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  license_type       = "BasePrice"
  sku_name           = "GP_Gen5"
  storage_size_in_gb = 32
  subnet_id          = azurerm_subnet.example.id
  vcores             = 4

  administrator_login          = "administrator"
  administrator_login_password = "password123#"

  
}
