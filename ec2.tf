# Define EC2 Instance inside the public subnet

data "aws_ami" "amzn" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
}

data "aws_ami" "rhel" {
  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-7.5_HVM_GA*"]
  }
}

data "aws_iam_policy" "ec2-readonly-policy" {
  arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}


resource "aws_iam_role" "ec2-readonly-role" {
  name = "ec2-readonly-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
    "Action": "sts:AssumeRole",
    "Principal": {
    "Service": "ec2.amazonaws.com"
    },
    "Effect": "Allow",
    "Sid": ""
  }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ec2-readonly-profile" {
  name  = "ec2-readonly-profile"
  role  = "${aws_iam_role.ec2-readonly-role.name}"
}

resource "aws_iam_role_policy_attachment" "attach-ec2-readonly-policy" {
  role       = "${aws_iam_role.ec2-readonly-role.name}"
  policy_arn = "${data.aws_iam_policy.ec2-readonly-policy.arn}"
}

resource "aws_instance" "bastion" {
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

resource "aws_instance" "jenkins" {
  ami = "${data.aws_ami.rhel.id}"
  instance_type = "t3.medium"
  key_name = "${aws_key_pair.default.id}"
  subnet_id = "${aws_subnet.private-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.sg_jenkins.id}"]
  associate_public_ip_address = false
  source_dest_check = true
  user_data = "${file("scripts/jenkins-master.sh")}"
  iam_instance_profile = "${aws_iam_instance_profile.ec2-readonly-profile.name}"

  root_block_device {
  volume_size = "${var.root_block_device_size}"
  }

  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "${var.data_volume_type}"
    volume_size = "${var.data_volume_size}"
  }

  tags {
    Name = "jenkins-master"
  }

  depends_on = ["aws_efs_mount_target.jenkins-master-priv1","aws_efs_mount_target.jenkins-master-priv1"]
}

resource "aws_lb_target_group_attachment" "jenkins-8080" {
  target_group_arn = "${aws_lb_target_group.jenkins-8080.arn}"
  target_id        = "${aws_instance.jenkins.id}"
  port             = 8080
}

resource "aws_instance" "git" {
  ami = "${data.aws_ami.amzn.id}"
  instance_type = "t3.medium"
  key_name = "${aws_key_pair.default.id}"
  subnet_id = "${aws_subnet.private-subnet2.id}"
  vpc_security_group_ids = ["${aws_security_group.sg_git.id}"]
  associate_public_ip_address = false
  source_dest_check = true
  user_data = "${file("scripts/git.sh")}"
  root_block_device {
  volume_size = "${var.root_block_device_size}"
  }
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "${var.data_volume_type}"
    volume_size = "${var.data_volume_size}"
  }
  tags {
    Name = "gitlab"
  }
}

resource "aws_lb_target_group_attachment" "git-80" {
  target_group_arn = "${aws_lb_target_group.git-80.arn}"
  target_id        = "${aws_instance.git.id}"
  port             = 80
}

resource "aws_lb" "alb_apps" {
  name               = "private-apps-alb"
  subnets            = ["${aws_subnet.public-subnet.id}", "${aws_subnet.public-subnet2.id}"]
  security_groups    = ["${aws_security_group.sg_git.id}", "${aws_security_group.sg_jenkins.id}"]
  internal           = false
  load_balancer_type = "application"
  tags = {
    Environment = "dev"
  }
}

resource "aws_lb" "alb_jenkins_slave" {
  name               = "jenkins-slave-alb"
  subnets            = ["${aws_subnet.public-subnet.id}", "${aws_subnet.public-subnet2.id}"]
  security_groups    = ["${aws_security_group.sg_jenkins.id}"]
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
    matcher = "200,403"
  }
}

resource "aws_lb_target_group" "jenkins-slave-8080" {
  name     = "jenkins-slave-8080"
  port     = 8080 
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.default.id}"
  health_check {
    path = "/"
    matcher = "200,403"
  }
}

resource "aws_lb_target_group" "git-80" {
  name     = "git-80"
  port     = 80 
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.default.id}"
  health_check {
    path = "/"
    matcher = "200,302"
  }
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

resource "aws_lb_listener" "jenkins-slave-8080" {
  load_balancer_arn = "${aws_lb.alb_jenkins_slave.id}"
  port              = "8080"
  protocol          = "HTTP"
  default_action {
    target_group_arn = "${aws_lb_target_group.jenkins-slave-8080.id}"
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

resource "aws_launch_configuration" "jenkins-slave" {
  name_prefix   = "jenkins-slave-"
  image_id      = "${data.aws_ami.rhel.id}"
  instance_type = "t3.medium"
  key_name = "${aws_key_pair.default.id}"
  security_groups = ["${aws_security_group.sg_jenkins.id}"]
  user_data = "${file("scripts/jenkins-slave.sh")}"
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

resource "aws_autoscaling_group" "jenkins-slave" {
  name                 = "jenkins-slave"
  launch_configuration = "${aws_launch_configuration.jenkins-slave.name}"
  min_size             = "${var.asg_jenkins_min}"
  max_size             = "${var.asg_jenkins_max}"
  desired_capacity     = "${var.asg_jenkins_desired}"
  vpc_zone_identifier  = ["${aws_subnet.private-subnet.id}", "${aws_subnet.private-subnet2.id}"]
  target_group_arns    = ["${aws_lb_target_group.jenkins-slave-8080.id}"]

  lifecycle {
    create_before_destroy = true
  }
  tag {
    key                 = "Name" 
    value               = "jenkins-slave"
    propagate_at_launch = true
  }
}

output "bastion_pub_ip" {
	value = "${aws_instance.bastion.public_ip}"
}
output "Load Balancer Public IP" {
	value = "${aws_lb.alb_apps.dns_name}"
}

