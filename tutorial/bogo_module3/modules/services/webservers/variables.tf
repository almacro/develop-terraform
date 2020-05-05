variable "aws_region" {
  description = "The AWS region to host the stack in"
  type = string
}

variable "server_port" {
  description = "The port the web server will be listening on"
  type        = number
  default     = 8080
}

variable "elb_port" {
  description = "The port the load balancer will be listening on"
  type        = number
  default     = 80
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type = string
}

variable "selected_vpc" {
  description = "Selected VPC to install in"
  type = string
}
