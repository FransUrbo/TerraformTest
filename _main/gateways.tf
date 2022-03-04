resource "aws_nat_gateway" "main" {
  count				= 1
  allocation_id			= "${element(aws_eip.main-nat.*.id, count.index)}"
  subnet_id			= "${element(aws_subnet.main_private.*.id, count.index)}"

  tags = {
    Name			= "main"
    service			= "network"
  }
}

resource "aws_eip" "main-nat" {
  count				= 1
  vpc				= "true"

  tags = {
    Name			= "main-nat_${count.index}"
  }
}

resource "aws_route" "main_private" {
  count				= 1
  route_table_id		= "${aws_route_table.main_private.id}"
  destination_cidr_block	= "0.0.0.0/0"

  nat_gateway_id		= "${element(aws_nat_gateway.main.*.id, count.index)}"
}
