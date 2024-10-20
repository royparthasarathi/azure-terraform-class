
resource "azurerm_resource_group" "rg" {
  name     = "class"
  location = "East US2"
}

resource "azurerm_storage_account" "storage" {
  name                     = "aemlabst9456243"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name                  = "data"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "container"
}
