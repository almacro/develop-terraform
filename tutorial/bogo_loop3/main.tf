terraform {
  required_version = ">= 0.12"
}

resource "aws_instance" "server" {
  count         = var.instances
  ami           = "ami-0d1cd67c26f5fca19"
  instance_type = "t3a.nano"

  tags = {
    Name = "Server ${count.index}"
  }
}
