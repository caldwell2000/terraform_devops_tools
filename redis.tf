resource "aws_elasticache_subnet_group" "gitlab_redis" {
  name       = "gitlab-redis-subnet-group"
  subnet_ids = ["${aws_subnet.private-subnet.id}", "${aws_subnet.private-subnet2.id}"]
}

resource "aws_elasticache_replication_group" "gitlab_redis" {
  replication_group_id          = "gitlab"
  replication_group_description = "Redis cluster powering GitLab"
  engine                        = "redis"
  node_type                     = "cache.m4.large"
  number_cache_clusters         = 2
  port                          = 6379
  availability_zones            = var.availability_zones
  automatic_failover_enabled    = true
  security_group_ids            = ["${aws_security_group.sg_redis.id}"]
  subnet_group_name             = "${aws_elasticache_subnet_group.gitlab_redis.name}"
}

output "gitlab_redis_endpoint_address" {
  value = "${aws_elasticache_replication_group.gitlab_redis.primary_endpoint_address}"
}
