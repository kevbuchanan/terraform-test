resource "aws_launch_configuration" "app_server" {
  name_prefix = "app-server-${terraform.workspace}-"
  image_id = "ami-2d39803a"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.web.id}"]
  user_data = <<-EOF
  #!/bin/bash
  echo "Hello, World" > index.html
  nohup busybox httpd -f &
  EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app_server" {
  name = "app-server-${terraform.workspace}-${aws_launch_configuration.app_server.name}"
  launch_configuration = "${aws_launch_configuration.app_server.id}"
  vpc_zone_identifier = [
    "${aws_subnet.public_subnet_1.id}",
    "${aws_subnet.public_subnet_2.id}",
  ]

  min_size = 2
  max_size = 5

  target_group_arns = ["${aws_alb_target_group.app_server_alb.arn}"]
  enabled_metrics = ["GroupInServiceInstances"]
  health_check_type = "EC2"

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      key = "Name"
      value = "app-server-asg-${terraform.workspace}-${count.index}"
      propagate_at_launch = true
    },
    {
      key = "Env"
      value = "${terraform.workspace}"
      propagate_at_launch = true
    }
  ]
}

resource "aws_alb" "app_server_alb" {
  name = "app-server-alb-${terraform.workspace}"
  security_groups = ["${aws_security_group.alb.id}"]
  subnets = [
    "${aws_subnet.public_subnet_1.id}",
    "${aws_subnet.public_subnet_2.id}",
  ]

  tags {
    Name = "app-server-alb-${terraform.workspace}"
    Env = "${terraform.workspace}"
  }
}

resource "aws_alb_target_group" "app_server_alb" {
  name = "app-server-alb-target"
  vpc_id = "${aws_vpc.default.id}"
  port = 80
  protocol = "HTTP"
  health_check {
    path = "/"
    matcher = "200,301"
    interval = "10"
  }
}

resource "aws_alb_listener" "app_server_alb_http" {
  load_balancer_arn = "${aws_alb.app_server_alb.arn}"
  port = 80
  protocol = "HTTP"
  default_action {
    target_group_arn = "${aws_alb_target_group.app_server_alb.arn}"
    type = "forward"
  }
}

output "app_server_alb_dns_name" {
  value = "${aws_alb.app_server_alb.dns_name}"
}
