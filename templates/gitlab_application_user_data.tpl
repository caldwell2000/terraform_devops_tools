#cloud-config
write_files:
  - content: |
      # Prevent GitLab from starting if NFS data mounts are not available
      high_availability['mountpoint'] = ['/var/opt/gitlab/git-data', '/var/opt/gitlab/.ssh', '/var/opt/gitlab/gitlab-rails/uploads', '/var/opt/gitlab/gitlab-rails/shared', '/var/opt/gitlab/gitlab-ci/builds']

      # Disabe built-in postgres and redis
      postgresql['enable'] = false
      redis['enable'] = false

      # External postgres settings
      gitlab_rails['db_adapter'] = "postgresql"
      gitlab_rails['db_encoding'] = "unicode"
      gitlab_rails['db_database'] = "${postgres_database}"
      gitlab_rails['db_username'] = "${postgres_username}"
      gitlab_rails['db_password'] = "${postgres_password}"
      gitlab_rails['db_host'] = "${postgres_endpoint}"
      gitlab_rails['db_port'] = 5432
      gitlab_rails['auto_migrate'] = false

      # External redis settings
      gitlab_rails['redis_host'] = "${redis_endpoint}"
      gitlab_rails['redis_port'] = 6379

      # Ensure UIDs and GIDs match between servers for permissions via NFS
      user['uid'] = 9000
      user['gid'] = 9000
      web_server['uid'] = 9001
      web_server['gid'] = 9001
      registry['uid'] = 9002
      registry['gid'] = 9002

      # Whitelist VPC cidr for access to health checks
      gitlab_rails['monitoring_whitelist'] = ['${cidr}']
    path: /etc/gitlab/gitlab.rb
    permissions: '0600'
runcmd:
  - [ gitlab-ctl, reconfigure ]
output: {all: '| tee -a /var/log/devops-cloud-init-output.log'}
