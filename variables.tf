provider "aws" {
	region =	"${var.aws_region}"
	profile	= 	"poc"

}

variable "region" {
	description = "Region Name"
	default = "us-east-2"
}

variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "us-east-2"
}

variable "remote_cidr" {
    description = "CIDR from Remote Testing Source"
    default = "173.172.103.202/32"
}

variable "vpc_name" {
    description = "Name Tag for VPC"
    default = "DevOps_dev"
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}

variable "public_subnet_2a_cidr" {
    description = "CIDR for the Public 2a Subnet"
    default = "10.0.0.0/25"
}

variable "public_subnet_2b_cidr" {
    description = "CIDR for the Public 2b Subnet"
    default = "10.0.0.128/25"
}

variable "private_subnet_2a_cidr" {
    description = "CIDR for the Private 2a Subnet"
    default = "10.0.1.0/25"
}

variable "private_subnet_2b_cidr" {
    description = "CIDR for the Private 2b Subnet"
    default = "10.0.1.128/25"
}

variable "private_db_subnet_2a_cidr" {
    description = "CIDR for the Private 2a Subnet"
    default = "10.0.2.0/25"
}

variable "private_db_subnet_2b_cidr" {
    description = "CIDR for the Private 2b Subnet"
    default = "10.0.2.128/25"
}
variable "key_path" {
  description = "SSH Public Key path"
  default = "C:/Users/caldwell/.ssh/id_rsa.pub"
}
variable "asg_jenkins_slave_min" {
  description = "Auto Scaling Minimum Size"
  default = "1"
}
variable "asg_jenkins_slave_max" {
  description = "Auto Scaling Maximum Size"
  default = "2"
}
variable "asg_jenkins_slave_desired" {
  description = "Auto Scaling Desired Size"
  default = "1"
}
variable "asg_jenkins_master_min" {
  description = "Auto Scaling Minimum Size"
  default = "1"
}
variable "asg_jenkins_master_max" {
  description = "Auto Scaling Maximum Size"
  default = "2"
}
variable "asg_jenkins_master_desired" {
  description = "Auto Scaling Desired Size"
  default = "1"
}
variable "asg_git_min" {
  description = "Auto Scaling Minimum Size"
  default = "1"
}
variable "asg_git_max" {
  description = "Auto Scaling Maximum Size"
  default = "2"
}
variable "asg_git_desired" {
  description = "Auto Scaling Desired Size"
  default = "2"
}
variable "data_volume_type" {
  description = "EBS Volume Type"
  default = "gp2"
}
variable "data_volume_size" {
  description = "EBS Volume Size"
  default = "50"
}
variable "root_block_device_size" {
  description = "Root EBS Volume Size"
  default = "50"
}
variable "gitlab_postgres_password" {
  default = "supersecret"
}
variable "git_rds_multiAZ" {
  default = "false"
}
variable "availability_zones" {
  type    = "list"
  default = ["us-east-2a", "us-east-2b"]
}

#ECS Variables
variable "AWS_ECR_REGION" {
  type    = "string"
  default = "us-east-2"
}

variable "TAG_ENV" {
  default = "dev"
}

variable "ENV" {
  default = "PROD"
}

variable "CIDR_PUBLIC" {
  default = "10.0.0.0/25,10.0.0.128/25"
}

variable "CIDR_PRIVATE" {
  default = "10.0.1.0/25,10.0.1.128/25"
}
