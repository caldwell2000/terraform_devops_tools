# MyApp - Static app mangaged by Terraform

data "template_file" "myapp" {
  template = "${file("templates/myapp.json.tpl")}"
  vars {
    REPOSITORY_URL = "${aws_ecr_repository.myapp.repository_url}"
    AWS_ECR_REGION = "${var.AWS_ECR_REGION}"
    LOGS_GROUP = "${aws_cloudwatch_log_group.myapp.name}"
  }
}

resource "aws_ecs_task_definition" "myapp" {
  family                = "myapp"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = 256
  memory = 512
  container_definitions = "${data.template_file.myapp.rendered}"
  execution_role_arn = "${aws_iam_role.ecsTaskExecutionRole.arn}"
  #execution_role_arn = "${aws_iam_role.ecs_task_assume.arn}"
  task_role_arn = "${aws_iam_role.ecs_task_assume.arn}"
}

resource "aws_ecs_service" "myapp" {
  name            = "myapp"
  cluster         = "${aws_ecs_cluster.fargate.id}"
  launch_type     = "FARGATE"
  task_definition = "${aws_ecs_task_definition.myapp.arn}"
  desired_count   = 3

  network_configuration = {
    subnets = ["${aws_subnet.private-subnet.id}", "${aws_subnet.private-subnet2.id}"]
    security_groups = ["${aws_security_group.ecs.id}"]
  }

  load_balancer {
   target_group_arn = "${aws_alb_target_group.myapp.arn}"
   container_name = "myapp"
   container_port = 3000
  }

  depends_on = [
    "aws_alb_listener.myapp"
  ]
}

# Hello-World - Application managed by Jenkins pipeline/githu
data "template_file" "hello-world" {
  template = "${file("templates/hello-world.json.tpl")}"
  vars {
    REPOSITORY_URL = "${aws_ecr_repository.hello-world.repository_url}"
    AWS_ECR_REGION = "${var.AWS_ECR_REGION}"
    LOGS_GROUP = "${aws_cloudwatch_log_group.hello-world.name}"
  }
}

resource "aws_ecs_task_definition" "hello-world" {
  family                = "hello-world"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = 256
  memory = 512
  container_definitions = "${data.template_file.hello-world.rendered}"
  execution_role_arn = "${aws_iam_role.ecsTaskExecutionRole.arn}"
  #execution_role_arn = "${aws_iam_role.ecs_task_assume.arn}"
  task_role_arn = "${aws_iam_role.ecs_task_assume.arn}"
}

resource "aws_ecs_service" "hello-world-service" {
  name            = "hello-world-service"
  cluster         = "${aws_ecs_cluster.fargate.id}"
  launch_type     = "FARGATE"
  task_definition = "${aws_ecs_task_definition.hello-world.arn}"
  desired_count   = 2

  network_configuration = {
    subnets = ["${aws_subnet.private-subnet.id}", "${aws_subnet.private-subnet2.id}"]
    security_groups = ["${aws_security_group.ecs.id}"]
  }

  load_balancer {
   target_group_arn = "${aws_alb_target_group.hello-world.arn}"
   container_name = "hello-world"
   container_port = 80
  }

  depends_on = [
    "aws_alb_listener.hello-world"
  ]
}
