resource "aws_security_group" "web" {
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "web"
    Env = "${terraform.workspace}"
  }
}

resource "aws_security_group" "alb" {
  vpc_id = "${aws_vpc.default.id}"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "alb"
    Env = "${terraform.workspace}"
  }
}

resource "aws_security_group" "icmp" {
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "icmp"
    Env = "${terraform.workspace}"
  }
}

resource "aws_security_group" "ssh" {
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "ssh"
    Env = "${terraform.workspace}"
  }
}
