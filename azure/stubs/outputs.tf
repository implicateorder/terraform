output "saname" {
  value = azurerm_storage_account.sa.name
}

output "sabootdiagname" {
  value = azurerm_storage_account.sabootdiag.name
}

output "blobname" {

  value = azurerm_storage_blob.lab.name
}

output "fsname" {
  value = azurerm_storage_share.fshare.name
}

output "containername" {
  value = azurerm_storage_container.sacontainer.name
}

output "blobendpoint" {
  value = azurerm_storage_account.sa.primary_blob_endpoint
}

output "rgname" {
  value = azurerm_resource_group.rg.name
}
output "rgid" {
  value = azurerm_resource_group.rg.id
}

output "rglocation" {
  value = azurerm_resource_group.rg.location
}

output "lbid" {
  value = azurerm_lb.lb.id
}

output "bepoolid" {
  value = azurerm_lb_backend_address_pool.bpepool.id
}

output "libnatpoolid" {
  value = azurerm_lb_nat_pool.lbnatpool.id
}

output "nsgname" {
  value = azurerm_network_security_group.nsg.name
}

output "nsgid" {
  value = azurerm_network_security_group.nsg.id
}

output "ssh_private_key" {
  value = tls_private_key.rsadmin_ssh.private_key_pem
}
output "ssh_pub_key" {
  value = tls_private_key.rsadmin_ssh.public_key_openssh
}