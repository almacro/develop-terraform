variable "aws_region" {
  default = "us-west-2"
}

variable "instance_type" {
  default = "t3a.nano"
}

variable "instance_tags" {
  type    = list
  default = ["Terraform-1", "Terraform-2"]
}

variable "instance_count" {
  default = 1
}

variable "ami" {
  type = map
  default = {
    us-east-1 = "ami-07ebfd5b3428b6f4d"
    us-west-1 = "ami-03ba3948f6c37a4b0"
    us-west-2 = "ami-0d1cd67c26f5fca19"
  }
}
