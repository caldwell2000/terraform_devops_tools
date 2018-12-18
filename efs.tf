# Jenkins-Master EFS Filesystems
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
  security_groups = ["${aws_security_group.efs-general.id}"]
}
resource "aws_efs_mount_target" "jenkins-master-priv2" {
  file_system_id = "${aws_efs_file_system.jenkins.id}"
  subnet_id      = "${aws_subnet.private-subnet2.id}"
  security_groups = ["${aws_security_group.efs-general.id}"]
}

# GitLab EFS Filesystems
# git ssh
resource "aws_efs_file_system" "git-ssh" {
  creation_token = "git-ssh-efs"
  encrypted = true
  kms_key_id = "${aws_kms_key.git-kms.arn}"

  tags = {
    Name = "git-ssh"
  }
}
resource "aws_efs_mount_target" "git-ssh-priv1" {
  file_system_id = "${aws_efs_file_system.git-ssh.id}"
  subnet_id      = "${aws_subnet.private-subnet.id}"
  security_groups = ["${aws_security_group.efs-general.id}"]
}
resource "aws_efs_mount_target" "git-ssh-priv2" {
  file_system_id = "${aws_efs_file_system.git-ssh.id}"
  subnet_id      = "${aws_subnet.private-subnet2.id}"
  security_groups = ["${aws_security_group.efs-general.id}"]
}

# git rails-rails-uploads
resource "aws_efs_file_system" "git-rails-uploads" {
  creation_token = "git-rails-uploads-efs"
  encrypted = true
  kms_key_id = "${aws_kms_key.git-kms.arn}"

  tags = {
    Name = "git-rails-uploads"
  }
}
resource "aws_efs_mount_target" "git-rails-uploads-priv1" {
  file_system_id = "${aws_efs_file_system.git-rails-uploads.id}"
  subnet_id      = "${aws_subnet.private-subnet.id}"
  security_groups = ["${aws_security_group.efs-general.id}"]
}
resource "aws_efs_mount_target" "git-rails-uploads-priv2" {
  file_system_id = "${aws_efs_file_system.git-rails-uploads.id}"
  subnet_id      = "${aws_subnet.private-subnet2.id}"
  security_groups = ["${aws_security_group.efs-general.id}"]
}

# git rails-shared
resource "aws_efs_file_system" "git-rails-shared" {
  creation_token = "git-rails-shared-efs"
  encrypted = true
  kms_key_id = "${aws_kms_key.git-kms.arn}"

  tags = {
    Name = "git-rails-shared"
  }
}
resource "aws_efs_mount_target" "git-rails-shared-priv1" {
  file_system_id = "${aws_efs_file_system.git-rails-shared.id}"
  subnet_id      = "${aws_subnet.private-subnet.id}"
  security_groups = ["${aws_security_group.efs-general.id}"]
}
resource "aws_efs_mount_target" "git-rails-shared-priv2" {
  file_system_id = "${aws_efs_file_system.git-rails-shared.id}"
  subnet_id      = "${aws_subnet.private-subnet2.id}"
  security_groups = ["${aws_security_group.efs-general.id}"]
}

# git builds
resource "aws_efs_file_system" "git-builds" {
  creation_token = "git-builds-efs"
  encrypted = true
  kms_key_id = "${aws_kms_key.git-kms.arn}"

  tags = {
    Name = "git-builds-efs"
  }
}
resource "aws_efs_mount_target" "git-builds-priv1" {
  file_system_id = "${aws_efs_file_system.git-builds.id}"
  subnet_id      = "${aws_subnet.private-subnet.id}"
  security_groups = ["${aws_security_group.efs-general.id}"]
}
resource "aws_efs_mount_target" "git-builds-priv2" {
  file_system_id = "${aws_efs_file_system.git-builds.id}"
  subnet_id      = "${aws_subnet.private-subnet2.id}"
  security_groups = ["${aws_security_group.efs-general.id}"]
}

# git data
resource "aws_efs_file_system" "git-data" {
  creation_token = "git-data-efs"
  encrypted = true
  kms_key_id = "${aws_kms_key.git-kms.arn}"

  tags = {
    Name = "git-data-efs"
  }
}
resource "aws_efs_mount_target" "git-data-priv1" {
  file_system_id = "${aws_efs_file_system.git-data.id}"
  subnet_id      = "${aws_subnet.private-subnet.id}"
  security_groups = ["${aws_security_group.efs-general.id}"]
}
resource "aws_efs_mount_target" "git-data-priv2" {
  file_system_id = "${aws_efs_file_system.git-data.id}"
  subnet_id      = "${aws_subnet.private-subnet2.id}"
  security_groups = ["${aws_security_group.efs-general.id}"]
}

