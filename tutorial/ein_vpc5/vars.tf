variable "aws_region" {
  description = "US WEST Oregon"
  default     = "us-west-2"
}

variable "vpc_cidr" {
  default = "10.20.0.0/16"
}

variable "azs" {
  type    = list
  default = ["us-west-2c", "us-west-2b", "us-west-2a", ]
}

variable "ec2_amis" {
  description = "Ubuntu Server 16.04 LTS (HVM)"
  type        = map
  default = {
    "us-east-1" = "ami-068944ec1ce6d4829"
    "us-east-2" = "ami-0765f2a0e038358f8"
    "us-west-1" = "ami-05add91e3c9ec59da"
    "us-west-2" = "ami-09eb6a1f3d27274e5"
  }
}

variable "public_subnets_cidr" {
  type    = list
  default = ["10.20.0.0/24", "10.20.2.0/24", "10.20.4.0/24"]
}

variable "private_subnets_cidr" {
  type    = list
  default = ["10.20.1.0/24", "10.20.3.0/24", "10.20.5.0/24"]
}

variable "nat_name" {
  default = "ec2-nat"
}

variable "instance_types" {
  type = list
  #  default = ["t3a.nano", "t3.nano"]
  default = ["t3a.nano"]
}

variable "extra_user_data" {
  description = "Adds on to instance user_data"
  default     = ""
}

