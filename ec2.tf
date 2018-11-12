# Define webserver inside the public subnet
resource "aws_instance" "wb" {
   ami  = "${lookup(var.ami, var.region)}"
   instance_type = "t2.micro"
   key_name = "${aws_key_pair.default.id}"
   subnet_id = "${aws_subnet.public-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.sgweb.id}"]
   associate_public_ip_address = true
   source_dest_check = false
   user_data = "${file("scripts/install_apache.sh")}"

  tags {
    Name = "webserver"
  }
}

output "Web_pub_ip" {
	value = "${aws_instance.wb.public_ip}"
}
