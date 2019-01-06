# MyApp
resource "aws_alb" "myapp" {
  name = "myapp"
  security_groups = ["${aws_security_group.ecs.id}", "${aws_security_group.alb.id}"]
  subnets = ["${aws_subnet.public-subnet.id}", "${aws_subnet.public-subnet2.id}"]
  internal = false
  tags = {
    Environment = "dev"
  }
}

resource "aws_alb_target_group" "myapp" {
  name = "myapp"
  protocol = "HTTP"
  port = "3000"
  vpc_id = "${aws_vpc.default.id}"
  target_type = "ip"

  health_check {
    path = "/"
  }
}

resource "aws_alb_listener" "myapp" {
  load_balancer_arn = "${aws_alb.myapp.arn}"
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.myapp.arn}"
    type = "forward"
  }

  depends_on = ["aws_alb_target_group.myapp"]
}

output "myapp_alb_dns_name" {
  value = "${aws_alb.myapp.dns_name}"
}

# Hello-World
resource "aws_alb" "hello-world" {
  name = "hello-world"
  security_groups = ["${aws_security_group.ecs.id}", "${aws_security_group.alb.id}"]
  subnets = ["${aws_subnet.public-subnet.id}", "${aws_subnet.public-subnet2.id}"]
  internal = false
  tags = {
    Environment = "dev"
  }
}

resource "aws_alb_target_group" "hello-world" {
  name = "hello-world"
  protocol = "HTTP"
  port = "80"
  vpc_id = "${aws_vpc.default.id}"
  target_type = "ip"

  health_check {
    path = "/"
  }
}

resource "aws_alb_listener" "hello-world" {
  load_balancer_arn = "${aws_alb.hello-world.arn}"
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.hello-world.arn}"
    type = "forward"
  }

  depends_on = ["aws_alb_target_group.hello-world"]
}

output "hello-world_alb_dns_name" {
  value = "${aws_alb.hello-world.dns_name}"
}
