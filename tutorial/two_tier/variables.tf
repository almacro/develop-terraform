variable "aws_region" {
  description = "AWS region to launch servers"
  default     = "us-west-2"
}

variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can connect.

Example: ~/.ssh/terraform.pub
DESCRIPTION  
}

variable "key_name" {
  description = "Desired name of AWS key pair"
}

variable "aws_amis" {
  default = {
    eu-west-1 = "ami-035966e8adab4aaad"
    us-east-1 = "ami-07ebfd5b3428b6f4d"
    us-west-1 = "ami-03ba3948f6c37a4b0"
    us-west-2 = "ami-0d1cd67c26f5fca19"
  }
}
