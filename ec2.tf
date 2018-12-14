# Define EC2 Instance inside the public subnet

data "aws_ami" "bitbucket" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Atlassian Bitbucket*"]
  }
}

data "aws_ami" "gitlab" {
  most_recent = true

  filter {
    name   = "name"
    values = ["GitLab CE*"]
  }
}

data "aws_ami" "rhel" {
  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-7.5_HVM_GA*"]
  }
}

resource "aws_instance" "bastion" {
#   ami  = "${lookup(var.ami, var.region)}"
   ami = "${data.aws_ami.rhel.id}"
   instance_type = "t3.micro"
   key_name = "${aws_key_pair.default.id}"
   subnet_id = "${aws_subnet.public-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.sgbastion.id}"]
   associate_public_ip_address = true
   source_dest_check = false
   user_data = "${file("scripts/patchOS.sh")}"

  tags {
    Name = "bastion"
  }
  root_block_device {
    volume_size = "100"
  }
}

resource "aws_lb" "alb_apps" {
  name               = "private-apps-alb"
  #subnets            = ["${aws_subnet.private-subnet.id}", "${aws_subnet.private-subnet2.id}"]
  subnets            = ["${aws_subnet.public-subnet.id}", "${aws_subnet.public-subnet2.id}"]
  security_groups    = ["${aws_security_group.sgapp.id}"]
  internal           = false
  load_balancer_type = "application"
  tags = {
    Environment = "dev"
  }
}

resource "aws_lb_target_group" "git-80" {
  name     = "git-80"
  port     = 80 
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.default.id}"
}

resource "aws_lb_target_group" "git-443" {
  name     = "git-443"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = "${aws_vpc.default.id}"
}

resource "aws_lb_target_group" "git-7990" {
  name     = "git-7990"
  port     = 7990
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.default.id}"
}

resource "aws_lb_listener" "git-7990" {
  load_balancer_arn = "${aws_lb.alb_apps.id}"
  port              = "7990"
  protocol          = "HTTP"
  default_action {
    target_group_arn = "${aws_lb_target_group.git-7990.id}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "git-443" {
  load_balancer_arn = "${aws_lb.alb_apps.id}"
  port              = "443"
  protocol          = "HTTP"
  default_action {
    target_group_arn = "${aws_lb_target_group.git-443.id}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "git-80" {
  load_balancer_arn = "${aws_lb.alb_apps.id}"
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = "${aws_lb_target_group.git-80.id}"
    type             = "forward"
  }
}

resource "aws_launch_configuration" "as_conf" {
  name_prefix   = "poc-"
  image_id      = "${data.aws_ami.rhel.id}"
  instance_type = "t3.medium"
  key_name = "${aws_key_pair.default.id}"
  security_groups = ["${aws_security_group.sgapp.id}"]
  user_data = "${file("scripts/git.sh")}"
  root_block_device {
    volume_size = "${var.root_block_device_size}"
  }

  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "${var.data_volume_type}"
    volume_size = "${var.data_volume_size}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "git" {
  name                 = "poc-git"
  launch_configuration = "${aws_launch_configuration.as_conf.name}"
  min_size             = "${var.asg_min}"
  max_size             = "${var.asg_max}"
  desired_capacity     = "${var.asg_desired}"
  vpc_zone_identifier  = ["${aws_subnet.private-subnet.id}", "${aws_subnet.private-subnet2.id}"]
  target_group_arns    = ["${aws_lb_target_group.git-80.id}", "${aws_lb_target_group.git-443.id}", "${aws_lb_target_group.git-7990.id}"]

  lifecycle {
    create_before_destroy = true
  }
}

output "bastion_pub_ip" {
	value = "${aws_instance.bastion.public_ip}"
}
output "Load Balancer Public IP" {
	value = "${aws_lb.alb_apps.dns_name}"
}

