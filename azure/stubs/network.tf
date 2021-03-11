resource "azurerm_virtual_network" "TFNet" {
  name = var.vnet_name
  address_space = [
   var.vnet_address_space]
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    environment = "Terraform VNET"
  }
}
# Create subnet
resource "azurerm_subnet" "tfsubnet" {
  name = var.subnet_name
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.TFNet.name
  address_prefix = var.subnet_address_prefix
}

#Deploy Public IP
resource "azurerm_public_ip" "pip01" {
  name = "pubip1"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Static"
  domain_name_label = azurerm_resource_group.rg.name
  sku = "Standard"
}
resource "azurerm_public_ip" "pip02" {
  name = "pubip2"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Static"
  # domain_name_label = azurerm_resource_group..name
  sku = "Standard"
}

resource "azurerm_public_ip" "pip03" {
  name = "pubip3"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Static"
  # domain_name_label = azurerm_resource_group..name
  sku = "Standard"
}

output "pip01id" {
  value = azurerm_public_ip.pip01.id
}

output "pip02id" {
  value = azurerm_public_ip.pip02.id
}

output "pip03id" {
  value = azurerm_public_ip.pip03.id
}

output "subnetid" {
  value = azurerm_subnet.tfsubnet.id
}

output "vnetid" {
  value = azurerm_virtual_network.TFNet.id
}