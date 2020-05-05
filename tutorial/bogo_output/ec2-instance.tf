resource "aws_key_pair" "terraform-demo" {
  key_name   = "terraform-demo"
  public_key = file("terraform-demo.pub")
}

resource "aws_instance" "import_example" {
  ami           = lookup(var.ami, var.aws_region)
  instance_type = var.instance_type
  key_name      = aws_key_pair.terraform-demo.key_name
}

resource "aws_instance" "my-instance" {
  count         = var.instance_count
  ami           = lookup(var.ami, var.aws_region)
  instance_type = var.instance_type

  key_name                    = aws_key_pair.terraform-demo.key_name
  subnet_id                   = var.selected_subnet
  vpc_security_group_ids      = [var.selected_security_group]
  associate_public_ip_address = true

  user_data = file("install_apache.sh")

  tags = {
    Name  = "Terraform-${count.index + 1}"
    Batch = "5AM"
  }
}
