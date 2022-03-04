resource "aws_vpc" "main" {
  cidr_block			= "10.0.0.0/16"

  enable_dns_support		= "true"
  enable_dns_hostnames		= "true"

  tags = {
    Name			= "main"
    service			= "network"
  }
}

# ===================================================

resource "aws_subnet" "main_private" {
  count				= "${length(var.availability_zones)}"
  vpc_id			= "${aws_vpc.main.id}"
  cidr_block			= "10.${element(split(".", aws_vpc.main.cidr_block), 1)}.${count.index}.0/24"
  availability_zone		= "${var.availability_zones[count.index]}"

  tags = {
    Name			= "main_private_${count.index}"
    service			= "network"
  }
}

resource "aws_route_table" "main_private" {
  vpc_id			= "${aws_vpc.main.id}"

  tags = {
    Name			= "main_private"
    service			= "network"
  }
}

resource "aws_route_table_association" "main_private" {
  count				= "${length(var.availability_zones)}"
  subnet_id			= "${element(aws_subnet.main_private.*.id, count.index)}"
  route_table_id		= "${aws_route_table.main_private.id}"
}

resource "aws_main_route_table_association" "main" {
  vpc_id			= "${aws_vpc.main.id}"
  route_table_id		= "${aws_route_table.main_private.id}"
}

# ===================================================

resource "aws_default_security_group" "main_default" {
  vpc_id			= "${aws_vpc.main.id}"

  ingress {
    protocol			= -1
    self			= true
    from_port			= 0
    to_port			= 0
  }

  egress {
    from_port			= 0
    to_port			= 0
    protocol			= "-1"
    cidr_blocks			= ["0.0.0.0/0"]
  }

  tags = {
    Name			= "main-default"
    service			= "network"
  }
}
