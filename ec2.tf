# Define EC2 Instance inside the public subnet

data "aws_ami" "amzn" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
}

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
  security_groups    = ["${aws_security_group.sg_git.id}", "${aws_security_group.sg_jenkins.id}"]
  internal           = false
  load_balancer_type = "application"
  tags = {
    Environment = "dev"
  }
}

resource "aws_lb_target_group" "jenkins-8080" {
  name     = "jenkins-8080"
  port     = 8080 
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.default.id}"
  health_check {
    path = "/"
    matcher = "403"
  }
}

resource "aws_lb_target_group" "git-80" {
  name     = "git-80"
  port     = 80 
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.default.id}"
}

resource "aws_lb_target_group" "git-7990" {
  name     = "git-7990"
  port     = 7990
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.default.id}"
}

resource "aws_lb_listener" "jenkins-8080" {
  load_balancer_arn = "${aws_lb.alb_apps.id}"
  port              = "8080"
  protocol          = "HTTP"
  default_action {
    target_group_arn = "${aws_lb_target_group.jenkins-8080.id}"
    type             = "forward"
  }
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

resource "aws_lb_listener" "git-80" {
  load_balancer_arn = "${aws_lb.alb_apps.id}"
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = "${aws_lb_target_group.git-80.id}"
    type             = "forward"
  }
}

resource "aws_launch_configuration" "git" {
  name_prefix   = "git-"
  image_id      = "${data.aws_ami.amzn.id}"
  instance_type = "t3.medium"
  key_name = "${aws_key_pair.default.id}"
  security_groups = ["${aws_security_group.sg_git.id}"]
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

resource "aws_launch_configuration" "jenkins" {
  name_prefix   = "jenkins-"
  image_id      = "${data.aws_ami.rhel.id}"
  instance_type = "t3.medium"
  key_name = "${aws_key_pair.default.id}"
  security_groups = ["${aws_security_group.sg_jenkins.id}"]
  user_data = "${file("scripts/jenkins.sh")}"
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

resource "aws_autoscaling_group" "jenkins" {
  name                 = "poc-jenkins"
  launch_configuration = "${aws_launch_configuration.jenkins.name}"
  min_size             = "${var.asg_jenkins_min}"
  max_size             = "${var.asg_jenkins_max}"
  desired_capacity     = "${var.asg_jenkins_desired}"
  vpc_zone_identifier  = ["${aws_subnet.private-subnet.id}", "${aws_subnet.private-subnet2.id}"]
  target_group_arns    = ["${aws_lb_target_group.jenkins-8080.id}"]

  lifecycle {
    create_before_destroy = true
  }
    tag {
        key = "Name"
        value = "jenkins"
        propagate_at_launch = true
    }
}

resource "aws_autoscaling_group" "git" {
  name                 = "poc-git"
  launch_configuration = "${aws_launch_configuration.git.name}"
  min_size             = "${var.asg_git_min}"
  max_size             = "${var.asg_git_max}"
  desired_capacity     = "${var.asg_git_desired}"
  vpc_zone_identifier  = ["${aws_subnet.private-subnet.id}", "${aws_subnet.private-subnet2.id}"]
  target_group_arns    = ["${aws_lb_target_group.git-80.id}", "${aws_lb_target_group.git-7990.id}"]

  lifecycle {
    create_before_destroy = true
  }
    tag {
        key = "Name"
        value = "git"
        propagate_at_launch = true
    }
}

output "bastion_pub_ip" {
	value = "${aws_instance.bastion.public_ip}"
}
output "Load Balancer Public IP" {
	value = "${aws_lb.alb_apps.dns_name}"
}

