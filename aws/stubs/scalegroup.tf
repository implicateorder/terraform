data "template_file" "install_apache" {
  template = "${file("${path.module}/install_apache.sh")}"
}

resource "aws_launch_template" "asgrptemplate" {
  name_prefix = "asgroup"
  image_id = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  #security_groups = [aws_security_group.secgroup.id]
  security_group_names = [
    aws_security_group.secgroup.name]
  user_data = "${base64encode(data.template_file.install_apache.template)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asgrp" {
  availability_zones = var.availability_zones
  desired_capacity = 3
  max_size = 5
  min_size = 1
  load_balancers = [
    aws_elb.elbdemo.name]
  health_check_type = "ELB"

  launch_template {
    id = aws_launch_template.asgrptemplate.id
    version = "$Latest"
  }
}