resource "aws_launch_template" "asgrptemplate" {
  name_prefix   = "asgroup"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
}

resource "aws_autoscaling_group" "asgrp" {
  availability_zones = var.availability_zones
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
    id      = aws_launch_template.asgrptemplate.id
    version = "$Latest"
  }
}