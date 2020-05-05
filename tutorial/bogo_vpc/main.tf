resource "aws_security_group" "instance" {
  name   = "terraform-example-instance"
  vpc_id = var.selected_vpc

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "terra-sample0" {
  ami           = "ami-0ce21b51cb31a48b8"
  instance_type = "t3a.nano"
  key_name      = var.selected_key_pair

  subnet_id  = var.selected_subnet
  security_groups             = [aws_security_group.instance.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y nmap-ncat
              mkdir -p /var/www && cd /var/www
              echo "I am terra-sample0" > index.html
              cat<<SCRIPT > server.sh
              #!/bin/bash
              while true; do
                printf 'HTTP/1.1 200 OK\n\n%s' "$(cat index.html)" | nc -l ${var.server_port}
              done
              SCRIPT
              chmod +x server.sh
              nohup /var/www/server.sh &
              EOF

  tags = {
    Name = "terra-sample0"
  }
}
