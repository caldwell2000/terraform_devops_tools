# MyApp
resource "aws_ecr_repository" "myapp" {
  name = "myapp"
}

output "myapp-repo" {
  value = "${aws_ecr_repository.myapp.repository_url}"
}

# Hello-World
resource "aws_ecr_repository" "hello-world" {
  name = "hello-world"
}

output "hello-world-repo" {
  value = "${aws_ecr_repository.hello-world.repository_url}"
}
