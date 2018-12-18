#cloud-config
write_files:
  - content: |
      # Prevent GitLab from starting if NFS data mounts are not available
      # Disabe built-in postgres and redis
      postgresql['enable'] = false
      # External postgres settings
      gitlab_rails['db_adapter'] = "postgresql"
      gitlab_rails['db_encoding'] = "unicode"
      gitlab_rails['db_database'] = "${postgres_database}"
      gitlab_rails['db_username'] = "${postgres_username}"
      gitlab_rails['db_password'] = "${postgres_password}"
      gitlab_rails['db_host'] = "${postgres_endpoint}"
      gitlab_rails['db_port'] = 5432
      gitlab_rails['auto_migrate'] = false
      # Whitelist VPC cidr for access to health checks
      gitlab_rails['monitoring_whitelist'] = ['${cidr}']
    path: /etc/gitlab/gitlab.rb
    permissions: '0600'
runcmd:
  - [ gitlab-ctl, reconfigure ]
output: {all: '| tee -a /var/log/devops-cloud-init-output.log'}
