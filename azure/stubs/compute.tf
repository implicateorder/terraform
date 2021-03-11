#Create NIC
resource "azurerm_network_interface" "nic01" {
  name = "nic01"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name = "ipconfig1"
    subnet_id = azurerm_subnet.tfsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip01.id
  }
}

resource "tls_private_key" "rsadmin_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

output "tls_private_key" {
  value = tls_private_key.rsadmin_ssh.private_key_pem
}

/*
data "templatefile" "install_apache" {
  template = "${file("${path.module}/install_apache.sh")}"
}

*/

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name = "mytestscaleset-1"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  instances = 3

  admin_username = "rsadmin"
  admin_password = "p@ssw0rd1234!"
  disable_password_authentication = false

  custom_data = base64encode(file("${path.module}/install_apache.sh"))

  source_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18.04-LTS"
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

resource "azurerm_virtual_machine_scale_set_extension" "vmss" {
  name                         = "vmss"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.vmss.id
  publisher                    = "Microsoft.Azure.Extensions"
  type                         = "CustomScript"
  type_handler_version         = "2.0"
  settings = jsonencode({
      "fileUris": ["https://raw.githubusercontent.com/Azure-Samples/compute-automation-configurations/master/automate_nginx.sh"],
      "commandToExecute": "./automate_nginx.sh"
  })
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
    storage_uri = azurerm_storage_account.sabootdiag.primary_blob_endpoint
  }
}

resource "azurerm_subnet_network_security_group_association" "nsghook01" {
  subnet_id = azurerm_subnet.tfsubnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
