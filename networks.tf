variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR for public subnet 1"
  default = "10.0.0.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR for public subnet 2"
  default = "10.0.1.0/24"
}

variable "private_subnet_1_cidr" {
  description = "CIDR for private subnet 1"
  default = "10.0.2.0/24"
}

variable "private_subnet_2_cidr" {
  description = "CIDR for private subnet 2"
  default = "10.0.3.0/24"
}

resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags {
    Name = "vpc-${terraform.workspace}"
    Env = "${terraform.workspace}"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "gateway-${terraform.workspace}"
    Env = "${terraform.workspace}"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "${var.public_subnet_1_cidr}"
  availability_zone = "us-east-1a"

  tags {
    Name = "public-subnet-1-${terraform.workspace}"
    Env = "${terraform.workspace}"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "${var.public_subnet_2_cidr}"
  availability_zone = "us-east-1b"

  tags {
    Name = "public-subnet-2-${terraform.workspace}"
    Env = "${terraform.workspace}"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "${var.private_subnet_1_cidr}"
  availability_zone = "us-east-1a"

  tags {
    Name = "private-subnet-1-${terraform.workspace}"
    Env = "${terraform.workspace}"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "${var.private_subnet_2_cidr}"
  availability_zone = "us-east-1b"

  tags {
    Name = "private-subnet-2-${terraform.workspace}"
    Env = "${terraform.workspace}"
  }
}

resource "aws_eip" "nat" {
  vpc = true
  depends_on = ["aws_internet_gateway.default"]
}

resource "aws_nat_gateway" "default" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id = "${aws_subnet.public_subnet_1.id}"
  depends_on = ["aws_internet_gateway.default"]

  tags {
    Name = "nat-gateway-${terraform.workspace}"
    Env = "${terraform.workspace}"
  }
}

resource "aws_route_table" "public_routes" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name = "public-subnet-routes-${terraform.workspace}"
    Env = "${terraform.workspace}"
  }
}

resource "aws_route_table" "private_routes" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.default.id}"
  }

  tags {
    Name = "private-subnet-routes-${terraform.workspace}"
    Env = "${terraform.workspace}"
  }
}

resource "aws_route_table_association" "route_public_subnet_1" {
  subnet_id = "${aws_subnet.public_subnet_1.id}"
  route_table_id = "${aws_route_table.public_routes.id}"
}

resource "aws_route_table_association" "route_public_subnet_2" {
  subnet_id = "${aws_subnet.public_subnet_2.id}"
  route_table_id = "${aws_route_table.public_routes.id}"
}

resource "aws_route_table_association" "route_private_subnet_1" {
  subnet_id = "${aws_subnet.private_subnet_1.id}"
  route_table_id = "${aws_route_table.private_routes.id}"
}

resource "aws_route_table_association" "route_private_subnet_2" {
  subnet_id = "${aws_subnet.private_subnet_2.id}"
  route_table_id = "${aws_route_table.private_routes.id}"
}
