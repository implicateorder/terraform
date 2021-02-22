output "public_ip" {
    value = aws_instance.vm.public_ip
}

output "ssh_private_key" {
    value = tls_private_key.sshkey.private_key_pem
}