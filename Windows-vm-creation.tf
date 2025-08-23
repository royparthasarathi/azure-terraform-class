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

resource "azurerm_resource_group" "rg" {
  name     = "RG11"
  location = "eastus2"
  
  tags = {
    Environment = "Terraform Getting Started"
    Team        = "DevOps"
  }
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "myTFVnet"
  address_space       = ["172.16.0.0/16"]
  location            = "eastus2"
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet for worksSN
resource "azurerm_subnet" "worksSN" {
  name                 = "worksSN"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["172.16.1.0/24"]
}

# Create Network Security Group with RDP rule
resource "azurerm_network_security_group" "rdp_nsg" {
  name                = "rdp-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSG with subnet
resource "azurerm_subnet_network_security_group_association" "worksSN_nsg" {
  subnet_id                 = azurerm_subnet.worksSN.id
  network_security_group_id = azurerm_network_security_group.rdp_nsg.id
}

# Create public IP
resource "azurerm_public_ip" "vm_public_ip" {
  name                = "vm-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Create network interface
resource "azurerm_network_interface" "vm_nic" {
  name                = "vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.worksSN.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }
}

# Create Windows Virtual Machine
resource "azurerm_windows_virtual_machine" "windows_vm" {
  name                = "windows-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2s"
  admin_username      = "Sysadmin"
  admin_password      = "Passw0rd123#" 
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  # Enable RDP by default
  provision_vm_agent = true
}

# Output the public IP for RDP connection
output "vm_public_ip" {
  value = azurerm_public_ip.vm_public_ip.ip_address
  description = "Public IP address for RDP connection"
}

# Output the admin username
output "admin_username" {
  value = azurerm_windows_virtual_machine.windows_vm.admin_username
  description = "Admin username for the Windows VM"
}
