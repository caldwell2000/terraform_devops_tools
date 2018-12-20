# Define the security group for private App subnet
resource "aws_security_group" "sg_git" {
  name = "git"
  description = "Allow traffic from public subnet"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.public_subnet_2a_cidr}"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.public_subnet_2b_cidr}"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
#cidr_blocks = ["${aws_nat_gateway.nat_gw1.public_ip}/31"]
    cidr_blocks = ["${format("%s/31", aws_nat_gateway.nat_gw1.public_ip)}"]
#Name = "${format("web-%03d", count.index + 1)}"
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${var.private_subnet_2a_cidr}", "${var.private_subnet_2b_cidr}", "${var.public_subnet_2a_cidr}", "${var.public_subnet_2b_cidr}", "${var.remote_cidr}"]
  }
  ingress {
    from_port = 7990
    to_port = 7990
    protocol = "tcp"
    cidr_blocks = ["${var.private_subnet_2a_cidr}", "${var.private_subnet_2b_cidr}", "${var.public_subnet_2a_cidr}", "${var.public_subnet_2b_cidr}", "${var.remote_cidr}"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.private_subnet_2a_cidr}", "${var.private_subnet_2b_cidr}", "${var.public_subnet_2a_cidr}", "${var.public_subnet_2b_cidr}", "${var.remote_cidr}"]
  }
  egress {
    from_port = 0
    to_port = 0 
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = "${aws_vpc.default.id}"
}
