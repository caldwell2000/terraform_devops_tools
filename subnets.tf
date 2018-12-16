# Define the public subnets
resource "aws_subnet" "public-subnet" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.public_subnet_2a_cidr}"
  availability_zone = "us-east-2a"

  tags {
    Name = "Web Public Subnet 1"
  }
}

resource "aws_subnet" "public-subnet2" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.public_subnet_2b_cidr}"
  availability_zone = "us-east-2b"

  tags {
    Name = "Web Public Subnet 2"
  }
}

# Define the private subnets
resource "aws_subnet" "private-subnet" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.private_subnet_2a_cidr}"
  availability_zone = "us-east-2a"

  tags {
    Name = "App Private Subnet 1"
  }
}

resource "aws_subnet" "private-subnet2" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.private_subnet_2b_cidr}"
  availability_zone = "us-east-2b"

  tags {
    Name = "App Private Subnet 2"
  }
}

# Define the DB subnets
resource "aws_subnet" "private-db-subnet" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.private_db_subnet_2a_cidr}"
  availability_zone = "us-east-2a"

  tags {
    Name = "Database Private Subnet 1"
  }
}

resource "aws_subnet" "private-db-subnet2" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.private_db_subnet_2b_cidr}"
  availability_zone = "us-east-2b"

  tags {
    Name = "Database Private Subnet 2"
  }
}
resource "aws_db_subnet_group" "default" {
  name       = "main-subnet-group"
  subnet_ids = ["${aws_subnet.private-db-subnet.id}", "${aws_subnet.private-db-subnet2.id}"]

  tags = {
    Name = "DB Subnet Group"
  }
}
