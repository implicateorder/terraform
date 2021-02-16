provider "aws" {
    region = "us-east-2"
}
resource "aws_instance" "tfexample" {
    ami		  = "ami-0ebc8f6f580a04647"
    instance_type = "t2.micro"
    tags = {
	Name = "terraform-example"
    }
}
