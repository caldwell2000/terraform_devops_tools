# Define the security group for public subnet
# Author: Richert Caldwell
resource "aws_security_group" "efs-general" {
  name = "sg_efs_general"
  description = "Allow incoming NFS ports"

  ingress {
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
    cidr_blocks = ["${var.private_subnet_2a_cidr}", "${var.private_subnet_2b_cidr}"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.private_subnet_2a_cidr}", "${var.private_subnet_2b_cidr}"]
  }
  egress {
    from_port = 0
    to_port = 0 
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id="${aws_vpc.default.id}"

  tags {
    Name = "EFS SG"
  }
}

resource "aws_security_group" "sgbastion" {
  name = "sg_bastion"
  description = "Allow incoming SSH access and ping"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["173.172.103.202/32"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["173.172.103.202/32"]
  }
  egress {
    from_port = 0
    to_port = 0 
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id="${aws_vpc.default.id}"

  tags {
    Name = "Bastion SG"
  }
}

# Define the security group for private App subnet
resource "aws_security_group" "sg_jenkins"{
  name = "sg_jenkins"
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
    from_port = 8080
    to_port = 8080
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

  tags {
    Name = "Jenkins SG"
  }
}

# Define the security group for private DB subnet
resource "aws_security_group" "sg_db"{
  name = "sg_db"
  description = "Allow traffic from public subnet"

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["${var.private_subnet_2a_cidr}"]
  }

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["${var.private_subnet_2b_cidr}"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.private_subnet_2a_cidr}"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.private_subnet_2b_cidr}"]
  }

  egress {
    from_port = 0
    to_port = 0 
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "DB SG"
  }
}

# Define the security group for Redis
resource "aws_security_group" "sg_redis"{
  name = "sg_redis"
  description = "Allow traffic from private subnet"

  ingress {
    from_port =6379 
    to_port = 6379
    protocol = "tcp"
    cidr_blocks = ["${var.private_subnet_2a_cidr}"]
  }

  ingress {
    from_port = 6379
    to_port =  6379
    protocol = "tcp"
    cidr_blocks = ["${var.private_subnet_2b_cidr}"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.private_subnet_2a_cidr}"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.private_subnet_2b_cidr}"]
  }

  egress {
    from_port = 0
    to_port = 0 
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "Redis SG"
  }
}

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
