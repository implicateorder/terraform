data "aws_availability_zones" "all" {}

resource "aws_elb" "elbdemo" {
  name               = "demoelb"
  security_groups    = [aws_security_group.secgroup.id]
  availability_zones = var.availability_zones

  health_check {
    target              = "HTTP:${var.server_port}/"
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  # Adding a listener for incoming HTTP requests.
  listener {
    lb_port           = var.elb_port
    lb_protocol       = "http"
    instance_port     = var.server_port
    instance_protocol = "http"
  }
  listener {
    instance_port = 22
    instance_protocol = "tcp"
    lb_port = 5022
    lb_protocol = "tcp"
  }
}

output "elb_dns_name" {
  value       = aws_elb.elbdemo.dns_name
  description = "The domain name of the load balancer"
}

