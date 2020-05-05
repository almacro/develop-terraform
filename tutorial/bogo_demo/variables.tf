variable "ami" {
  type = map(string)
  default = {
    eu-west-1 = "ami-035966e8adab4aaad"
    us-east-1 = "ami-07ebfd5b3428b6f4d"
    us-west-1 = "ami-03ba3948f6c37a4b0"
    us-west-2 = "ami-0d1cd67c26f5fca19"
  }
}

variable "instance_type" {
  default = "t3a.nano"
}

variable "instance_count" {
  default = 2
}

variable "aws_region" {
  default = "us-west-2"
}

variable "selected_subnet" {
  description = "Selected subnet to deploy instance on"
}

variable "selected_security_group" {
  description = "Selected security group to deploy instance on"
}
