resource "azurerm_storage_account" "sa" {
  name = var.storage_account_name
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_tier = var.account_tier
  account_replication_type = var.account_repl_type

}

# Your Terraform code goes here...

resource "azurerm_storage_container" "sacontainer" {
  name = var.storage_container_name
  storage_account_name = azurerm_storage_account.sa.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "lab" {
  name = var.storage_blob_name
  storage_account_name = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.sacontainer.name
  type = "Block"
}
resource "azurerm_storage_share" "fshare" {
  name = var.storage_share_name
  storage_account_name = azurerm_storage_account.sa.name
  quota = 50
}

#Create Boot Diagnostic Account
resource "azurerm_storage_account" "sabootdiag" {
  name = var.bootdiag_storage_account_name
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_tier = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "Boot Diagnostic Storage"
    CreatedBy = "Admin"
  }
}
