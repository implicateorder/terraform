variable "instance_name" {}
variable "ami" {}
variable "instance_type" {}
variable "security_group" {}
variable "key_name" {}
variable "availability_zones" {
  type = list(string)
  default = []
}
variable "server_port" {}
variable "elb_port" {}
/*
variable "vpc_name" {}
variable "vpc_cidr_block" {}
variable "subnet_name" {}
variable "subnet_cidr_block" {}
variable "elb_name" {}*/
