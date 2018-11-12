#variable "aws_access_key" {}
#variable "aws_secret_key" {}
#variable "aws_key_path" {}
#variable "aws_key_name" {}

variable "region" {
	description = "Region Name"
	default = "us-east-2"
}

variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "us-east-2"
}

variable "ami" {
    description = "AMIs by region"
    default = {
        us-east-2 = "ami-03291866" # Red Hat Enterprise Linux 7.5
    }
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
  default = "C:/Users/rcald/.ssh/id_rsa.pub"
}