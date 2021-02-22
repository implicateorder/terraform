resource "aws_instance" "vm" {
    ami = var.ami
    instance_type = var.instance_type
    vpc_security_group_ids = [aws_security_group.secgroup.id]
    key_name = aws_key_pair.generated_key.key_name
   /* user_data = <<-EOF
	  	#!/bin/bash
		echo "Hello World!" > index.html
		nohup busybox httpd -f -p 8080 &
		EOF*/
    tags = {
	Name = "terraform-example"
    }
}
