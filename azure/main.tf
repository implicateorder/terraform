# variable "client_secret" {
# }

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
  subscription_id = "bd3f23d0-fa9a-4f6f-a687-8927ac162466"
  client_id = "1511e367-2634-4f67-88d0-5a72874fd175"
  client_secret = "VmXpH3P.J_-I0FQ2rNyvefVim2eG4COW65"
  tenant_id = "dab47f95-511f-486c-8f0a-b21ed0da3a79"
}

resource "azurerm_resource_group" "rg" {
  name = "ktterraform-rg"
  location = "Central US"

  tags = {
    environment = "Terraform Kicktires"
    CreatedBy = "Admin"
  }
}

resource "azurerm_storage_account" "sa" {
  name = "terrastorerealsysadmin"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_tier = "Standard"
  account_replication_type = "LRS"

}

# Your Terraform code goes here...

resource "azurerm_storage_container" "sacontainer" {
  name = "blobcontainer4realsysadmin"
  storage_account_name = azurerm_storage_account.sa.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "lab" {
  name = "terraformblob"
  storage_account_name = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.sacontainer.name
  type = "Block"
}
resource "azurerm_storage_share" "fshare" {
  name = "terraformshare"
  storage_account_name = azurerm_storage_account.sa.name
  quota = 50
}
# Create virtual network
resource "azurerm_virtual_network" "TFNet" {
  name = "TFVnet"
  address_space = [
    "10.0.0.0/16"]
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    environment = "Terraform VNET"
  }
}
# Create subnet
resource "azurerm_subnet" "tfsubnet" {
  name = "default"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.TFNet.name
  address_prefix = "10.0.1.0/24"
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
  sku = "Basic"
}

#Create NIC
resource "azurerm_network_interface" "nic01" {
  name = "nic01"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name = "ipconfig1"
    subnet_id = azurerm_subnet.tfsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip02.id
  }
}

#Create Boot Diagnostic Account
resource "azurerm_storage_account" "sabootdiag" {
  name = "ktterraformsabdiag"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_tier = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "Boot Diagnostic Storage"
    CreatedBy = "Admin"
  }
}

resource "tls_private_key" "rsadmin_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

output "tls_private_key" {
  value = tls_private_key.rsadmin_ssh.private_key_pem
}

resource "azurerm_lb" "lb" {
  name = "lb01"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku = "Standard"

  frontend_ip_configuration {
    name = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.pip01.id
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

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name = "mytestscaleset-1"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  instances = 3
  admin_username = "rsadmin"
  admin_password = "p@ssw0rd1234!"
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04-LTS"
    version = "latest"
  }

  network_interface {
    name = "vmssnic"
    primary = true

    ip_configuration {
      name = "internal"
      primary = true
      subnet_id = azurerm_subnet.tfsubnet.id
      load_balancer_backend_address_pool_ids = [
        azurerm_lb_backend_address_pool.bpepool.id]
      load_balancer_inbound_nat_rules_ids = [
        azurerm_lb_nat_pool.lbnatpool.id]
    }
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching = "ReadWrite"
  }

  admin_ssh_key {
    # path     = "/home/rsadmin/.ssh/authorized_keys"
    # key_data = tls_private_key.rsadmin_ssh.public_key_openssh
    public_key = tls_private_key.rsadmin_ssh.public_key_openssh
    username = "rsadmin"
  }
  sku = "Standard_F2"

  tags = {
    environment = "staging"
  }
}

#Create Virtual Machine
resource "azurerm_virtual_machine" "vm01" {
  name = "vm01"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  network_interface_ids = [
    azurerm_network_interface.nic01.id]
  vm_size = "Standard_B1s"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true



  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04-LTS"
    version = "latest"
  }

  storage_os_disk {
    name = "osdisk1"
    disk_size_gb = "128"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name = "vm01"
    admin_username = "rsadmin"
    admin_password = "p@$$w0rd123"
    # disable_password_authentication = true
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
  # ssh_keys {
  #   username   = "rsadmin"
  #   public_key = tls_private_key.rsadmin_ssh.public_key_openssh
  # }

  boot_diagnostics {
    enabled = "true"
    storage_uri = azurerm_storage_account.sa.primary_blob_endpoint
  }
}

resource "azurerm_network_security_group" "nsg" {
  name = "nsg01"
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
#  resource_group_name         = "185-f1367afd-create-azure-nsgs-with-terraform-8w8"
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

resource "azurerm_subnet_network_security_group_association" "nsghook01" {
  subnet_id = azurerm_subnet.tfsubnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# resource "azurerm_network_interface_backend_address_pool_association" "bepoolassoc" {
# network_interface_name = azurerm_linux_virtual_machine_scale_set.vmss.network_interface.name
#   ip_configuration_name   = azurerm_linux_virtual_machine_scale_set.vmss.name
#  backend_address_pool_id = azurerm_lb_backend_address_pool.bpepool.id
# network_interface_id = azurerm_linux_virtual_machine_scale_set.vmss.network_interface
# }