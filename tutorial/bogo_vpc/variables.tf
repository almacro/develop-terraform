variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "selected_vpc" {
  description = "Selected VPC to install in"
}

variable "selected_key_pair" {
  description = "Selected key pair to install on instances"
}

variable "selected_subnet" {
  description = "Selected subnet to install on"
}