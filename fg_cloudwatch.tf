resource "aws_cloudwatch_log_group" "myapp" {
  name              = "/ecs/myapp"
  retention_in_days = 30
  tags {
    Name = "myapp"
  }
}
resource "aws_cloudwatch_log_group" "hello-world" {
  name              = "/ecs/hello-world"
  retention_in_days = 30
  tags {
    Name = "hello-world"
  }
}
