# Define EC2 Instance inside the public subnet

data "aws_ami" "amzn" {
  most_recent = true
  owners      = ["137112412989"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
}

data "aws_ami" "rhel" {
  most_recent = true
  owners      = ["309956199498"]
  filter {
    name   = "name"
    values = ["RHEL-7.5_HVM_GA*"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = "${data.aws_ami.rhel.id}"
  instance_type               = "t3.micro"
  key_name                    = "${aws_key_pair.default.id}"
  subnet_id                   = "${aws_subnet.public-subnet.id}"
  vpc_security_group_ids      = ["${aws_security_group.sgbastion.id}"]
  associate_public_ip_address = true
  source_dest_check           = false
  user_data                   = "${file("scripts/patchOS.sh")}"

  tags = {
    Name = "bastion"
  }
  root_block_device {
    volume_size = "100"
  }
}
