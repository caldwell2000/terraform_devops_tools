resource "aws_db_instance" "gitlab_postgres" {
  allocated_storage      = 50
  storage_type           = "gp2"
  engine                 = "postgres"
#  engine_version         = "9.6.6"
  instance_class         = "db.m4.large"
  multi_az               = true
  db_subnet_group_name   = "${aws_db_subnet_group.default.name}"
  name                   = "gitlab"
  username               = "gitlab"
  password               = "${var.gitlab_postgres_password}"
  vpc_security_group_ids = ["${aws_security_group.sg_db.id}"]
}

output "gitlab_postgres_address" {
  value = "${aws_db_instance.gitlab_postgres.address}"
}
