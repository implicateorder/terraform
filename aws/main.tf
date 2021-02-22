provider "aws" {
    region = var.region
}

module "stubs" {
    source = "./stubs"
    ami		  = "ami-0ebc8f6f580a04647"
    instance_type = "t2.micro"
    instance_name = "testvm01"
    security_group = "instaprot"
    key_name = "sshkey2021"
    availability_zones = ["us-east-2a"]
}

output "public_ip" {
    value = module.stubs.public_ip
}

output "ssh_private_key" {
    value = module.stubs.ssh_private_key
}
