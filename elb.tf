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

resource "aws_lb_target_group" "jenkins-master-8080" {
  name     = "jenkins-master-8080"
  port     = 8080 
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.default.id}"
  health_check {
    path = "/"
    interval = 8
    healthy_threshold = 2
    unhealthy_threshold = 2
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
    interval = 8
    healthy_threshold = 2
    unhealthy_threshold = 2
    matcher = "200,302"
  }
}

resource "aws_lb_listener" "jenkins-master-8080" {
  load_balancer_arn = "${aws_lb.alb_apps.id}"
  port              = "8080"
  protocol          = "HTTP"
  default_action {
    target_group_arn = "${aws_lb_target_group.jenkins-master-8080.id}"
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
  associate_public_ip_address = false
  user_data = "${data.template_cloudinit_config.config.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.ec2-readonly-profile.name}"
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

resource "aws_launch_configuration" "jenkins-master" {
  name_prefix   = "jenkins-master-"
  image_id      = "${data.aws_ami.rhel.id}"
  instance_type = "t3.medium"
  key_name = "${aws_key_pair.default.id}"
  security_groups = ["${aws_security_group.sg_jenkins.id}"]
  user_data = "${file("scripts/jenkins-master.sh")}"
  associate_public_ip_address = false
  iam_instance_profile = "${aws_iam_instance_profile.ec2-readonly-profile.name}"
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
  depends_on = ["aws_nat_gateway.nat_gw1"]
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

resource "aws_autoscaling_group" "jenkins-master" {
  name                 = "jenkins-master"
  launch_configuration = "${aws_launch_configuration.jenkins-master.name}"
  min_size             = "${var.asg_jenkins_master_min}"
  max_size             = "${var.asg_jenkins_master_max}"
  desired_capacity     = "${var.asg_jenkins_master_desired}"
  vpc_zone_identifier  = ["${aws_subnet.private-subnet.id}", "${aws_subnet.private-subnet2.id}"]
  target_group_arns    = ["${aws_lb_target_group.jenkins-master-8080.id}"]
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key                 = "Name" 
    value               = "jenkins-master"
    propagate_at_launch = true
  }
  depends_on = ["aws_efs_mount_target.jenkins-master-priv1","aws_efs_mount_target.jenkins-master-priv2"]
}

resource "aws_autoscaling_group" "jenkins-slave" {
  name                 = "jenkins-slave"
  launch_configuration = "${aws_launch_configuration.jenkins-slave.name}"
  min_size             = "${var.asg_jenkins_slave_min}"
  max_size             = "${var.asg_jenkins_slave_max}"
  desired_capacity     = "${var.asg_jenkins_slave_desired}"
  vpc_zone_identifier  = ["${aws_subnet.private-subnet.id}", "${aws_subnet.private-subnet2.id}"]
#  target_group_arns    = ["${aws_lb_target_group.jenkins-slave-8080.id}"]
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key                 = "Name" 
    value               = "jenkins-slave"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "git" {
  name                 = "git"
  launch_configuration = "${aws_launch_configuration.git.name}"
  min_size             = "${var.asg_git_min}"
  max_size             = "${var.asg_git_max}"
  desired_capacity     = "${var.asg_git_desired}"
  vpc_zone_identifier  = ["${aws_subnet.private-subnet.id}", "${aws_subnet.private-subnet2.id}"]
  target_group_arns    = ["${aws_lb_target_group.git-80.id}"]
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key                 = "Name"
    value               = "gitlab"
    propagate_at_launch = true
  }
  depends_on = ["aws_db_instance.gitlab_postgres","aws_efs_mount_target.git-ssh-priv1","aws_efs_mount_target.git-ssh-priv2","aws_efs_mount_target.git-rails-uploads-priv1","aws_efs_mount_target.git-rails-uploads-priv2","aws_efs_mount_target.git-rails-shared-priv1","aws_efs_mount_target.git-rails-shared-priv2","aws_efs_mount_target.git-builds-priv1","aws_efs_mount_target.git-builds-priv2","aws_efs_mount_target.git-data-priv1","aws_efs_mount_target.git-data-priv2"]
}
