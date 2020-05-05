provider "aws" {
  region = "us-west-2"
}

resource "aws_key_pair" "terraform-demo" {
  key_name   = "terraform-demo"
  public_key = file("terraform-demo.pub")
}

resource "aws_instance" "busybox_web_server" {
  ami           = "ami-0d1cd67c26f5fca19"
  instance_type = "t3a.nano"

  key_name                    = aws_key_pair.terraform-demo.key_name
  subnet_id                   = var.selected_subnet
  vpc_security_group_ids      = [aws_security_group.busybox.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, Terraform & AWS" > index.html
              nohup busybox httpd -f -p ${var.http_port} &
              EOF

  tags = {
    Name = "busybox web server created by Terraform"
  }
}

resource "aws_security_group" "busybox" {
  name   = "terraform-busybox-sg"
  vpc_id = data.aws_vpc.selected.id

  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "http_port" {
  description = "The port the web server will be listening on"
  type        = number
  default     = 8080
}

data "aws_vpc" "selected" {
  id = var.selected_vpc
}

output "public_ip" {
  value       = aws_instance.busybox_web_server.public_ip
  description = "The public IP of the web server"
}
