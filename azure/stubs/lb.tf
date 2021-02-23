resource "azurerm_lb" "lb" {
  name = var.lb_name
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku = "Standard"

  frontend_ip_configuration {
    name = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.pip02.id
  }
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id = azurerm_lb.lb.id
  name = "BackEndAddressPool"

}

resource "azurerm_lb_nat_pool" "lbnatpool" {
  resource_group_name = azurerm_resource_group.rg.name
  name = "ssh"
  loadbalancer_id = azurerm_lb.lb.id
  protocol = "Tcp"
  frontend_port_start = 50000
  frontend_port_end = 50119
  backend_port = 22
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_lb_probe" "lbprobe" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id = azurerm_lb.lb.id
  name = "http-probe"
  protocol = "Http"
  request_path = "/health"
  port = 8080
}
