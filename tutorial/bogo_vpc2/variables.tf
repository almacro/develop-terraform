variable "aws_region" {
  default = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR to use for new VPC"
  default = "10.20.0.0/16"
}

variable "subnets_cidr" {
  type    = list
  default = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "azs" {
  type    = list
  default = ["us-west-2c", "us-west-2b"]
}

variable "webservers_ami" {
  default = "ami-0ce21b51cb31a48b8"
}

variable "instance_type" {
  default = "t3a.nano"
}
