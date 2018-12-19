// terraform/main.tf

data "template_file" "shell-script" {
  template = "${file("scripts/git.sh")}"
}

# Render a part using a `template_file` for customizing GitLab configuration
data "template_file" "gitlab_application_user_data" {
  template = "${file("templates/gitlab_application_user_data.tpl")}"
  vars {
    postgres_database     = "${aws_db_instance.gitlab_postgres.name}"
    postgres_username     = "${aws_db_instance.gitlab_postgres.username}"
    postgres_password     = "${var.gitlab_postgres_password}"
    postgres_endpoint     = "${aws_db_instance.gitlab_postgres.address}"
    redis_endpoint        = "${aws_elasticache_replication_group.gitlab_redis.primary_endpoint_address}"
    cidr                  = "${var.vpc_cidr}"
    gitlab_url            = "http://${aws_lb.alb_apps.dns_name}"
  }
}

# Render a multi-part cloudinit config making use of the part
# above, and other source files
data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "gitlab_application_user_data.tpl"
    content_type = "text/cloud-config"
    content      = "${data.template_file.gitlab_application_user_data.rendered}"
  }

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.shell-script.rendered}"
  }
}
output "GitLab One-Time DB Creation Command - Primary Only" {
        value = "force=yes; export force; gitlab-rake gitlab:setup"
}
output "GitLab One-Time DB Creation Command - Primary Only (2)" {
        value = "sudo gitlab-ctl reconfigure"
}
output "GitLab Run one time on each secondary instance" {
        value = "Configure shared secrets. These values can be obtained from the primary GitLab server in /etc/gitlab/gitlab-secrets.json. Copy this file to the secondary servers prior to running the first reconfigure in the steps above"
}
output "GitLab Run one time on each secondary instance (2)" {
        value = "touch /etc/gitlab/skip-auto-reconfigure"
}
output "bastion_pub_ip" {
        value = "${aws_instance.bastion.public_ip}"
}
output "Load Balancer Public IP" {
        value = "${aws_lb.alb_apps.dns_name}"
}


