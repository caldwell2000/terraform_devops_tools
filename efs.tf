resource "aws_efs_file_system" "jenkins" {
  creation_token = "jenkins-efs"
  encrypted = true
  kms_key_id = "${aws_kms_key.jenkins-kms.arn}"

  tags = {
    Name = "jenkins-efs"
  }
}
resource "aws_efs_mount_target" "jenkins-master-priv1" {
  file_system_id = "${aws_efs_file_system.jenkins.id}"
  subnet_id      = "${aws_subnet.private-subnet.id}"
  security_groups = ["${aws_security_group.jenkins-efs.id}"]
}
resource "aws_efs_mount_target" "jenkins-master-priv2" {
  file_system_id = "${aws_efs_file_system.jenkins.id}"
  subnet_id      = "${aws_subnet.private-subnet2.id}"
  security_groups = ["${aws_security_group.jenkins-efs.id}"]
}
