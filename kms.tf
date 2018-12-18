resource "aws_kms_key" "jenkins-kms" {
  description = "Encrypt data at rest in EFS"
  policy = "{\"Statement\": {\"Action\": \"kms:*\", \"Effect\": \"Allow\", \"Principal\": \"*\", \"Resource\": \"*\", \"Sid\": \"Enable IAM User Permissions\"}, \"Version\": \"2012-10-17\"}"  
}
resource "aws_kms_key" "git-kms" {
  description = "Encrypt data at rest in EFS"
  policy = "{\"Statement\": {\"Action\": \"kms:*\", \"Effect\": \"Allow\", \"Principal\": \"*\", \"Resource\": \"*\", \"Sid\": \"Enable IAM User Permissions\"}, \"Version\": \"2012-10-17\"}"  
}
