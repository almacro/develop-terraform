variable "vpc_cidr" {
  default = "10.20.0.0/16"
}

variable "availability_zones" {
  default = ["us-west-2c", "us-west-2a", ]
}

variable "public_subnets_cidr" {
  type    = list
  default = ["10.20.2.0/24", "10.20.4.0/24"]
}

variable "private_subnets_cidr" {
  type    = list
  default = ["10.20.3.0/24", "10.20.5.0/24"]
}

variable "nat_name" {
  default = "nat"
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

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "selected_key_pair" {
  description = "Selected key pair to initialize instances with"
  type = string
}