terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # version = "=2.46.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "stubs" {
  source = "./stubs"
  vnet_name = "kt-vnet"
  subnet_name = "kt-subnet1"
  vnet_address_space = "10.0.0.0/16"
  subnet_address_prefix = "10.0.1.0/24"
  lb_name = "kt-lb"
  storage_account_name = "ktsa"
  storage_container_name = "kt-sa-bc"
  storage_blob_name = "kt-blob"
  storage_share_name = "kt-share"
  bootdiag_storage_account_name = "ktbootdiag"
  account_tier = "Standard"
  account_repl_type = "LRS"
  nsg_name = "kt-secure"
  resource_group_name = "kicktires-rg"
  resource_group_location = "Central US"
}

# resource "azurerm_network_interface_backend_address_pool_association" "bepoolassoc" {
# network_interface_name = azurerm_linux_virtual_machine_scale_set.vmss.network_interface.name
#   ip_configuration_name   = azurerm_linux_virtual_machine_scale_set.vmss.name
#  backend_address_pool_id = azurerm_lb_backend_address_pool.bpepool.id
# network_interface_id = azurerm_linux_virtual_machine_scale_set.vmss.network_interface
# }

output "ssh_private_key" {
  value = module.stubs.ssh_private_key
}