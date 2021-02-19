resource "azurerm_network_security_group" "nsg" {
  name = var.nsg_name
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "allow_ib_http" {
  name = "Web80"
  priority = 1001
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "80"
  destination_port_range = "80"
  source_address_prefix = "*"
  destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

#resource "azurerm_network_security_rule" "example2" {
#  name                        = "Web8080"
#  priority                    = 1000
#  direction                   = "Inbound"
#  access                      = "Deny"
#  protocol                    = "Tcp"
#  source_port_range           = "8080"
#  destination_port_range      = "8080"
#  source_address_prefix       = "*"
##  destination_address_prefix  = "*"
#  resource_group_name         = var.rg_name
#  network_security_group_name = azurerm_network_security_group.nsg.name
#}

resource "azurerm_network_security_rule" "allow_ib_ssh" {
  name = "SSH"
  priority = 1100
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "22"
  source_address_prefix = "*"
  destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "allow_ob_http" {
  name = "Web80Out"
  priority = 1000
  direction = "Outbound"
  access = "Deny"
  protocol = "Tcp"
  source_port_range = "80"
  destination_port_range = "80"
  source_address_prefix = "*"
  destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}
