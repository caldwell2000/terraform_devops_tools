resource "aws_db_instance" "gitlab_postgres" {
  allocated_storage      = 50
  storage_type           = "gp2"
  engine                 = "postgres"
  instance_class         = "db.m4.large"
  multi_az               = "${var.git_rds_multiAZ}"
  db_subnet_group_name   = "${aws_db_subnet_group.default.name}"
  name                   = "gitlab"
  identifier		 = "gitlab"
  username               = "gitlab"
  password               = "${var.gitlab_postgres_password}"
  vpc_security_group_ids = ["${aws_security_group.sg_db.id}"]
  skip_final_snapshot    = true
}

output "gitlab_postgres_address" {
  value = "${aws_db_instance.gitlab_postgres.address}"
}
