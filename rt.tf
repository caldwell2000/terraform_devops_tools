# Define the route table
resource "aws_route_table" "public-rt" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
  tags {
    Name = "Public Subnet RT"
  }
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "public-rt1" {
  subnet_id = "${aws_subnet.public-subnet.id}"
  route_table_id = "${aws_route_table.public-rt.id}"
}

resource "aws_route_table_association" "public-rt2" {
  subnet_id = "${aws_subnet.public-subnet2.id}"
  route_table_id = "${aws_route_table.public-rt.id}"
}

resource "aws_route_table" "private-rt" {
  vpc_id = "${aws_vpc.default.id}"
  route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.nat_gw1.id}"
  }
  tags {
      Name = "Private Subnet RT"
  }
}

resource "aws_route_table_association" "private-rt1" {
  subnet_id = "${aws_subnet.private-subnet.id}"
  route_table_id = "${aws_route_table.private-rt.id}"
}

resource "aws_route_table_association" "private-rt2" {
  subnet_id = "${aws_subnet.private-subnet2.id}"
  route_table_id = "${aws_route_table.private-rt.id}"
}
