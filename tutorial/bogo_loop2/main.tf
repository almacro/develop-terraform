terraform {
  required_version = ">= 0.12"
}

data "aws_availability_zones" "all" {}

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.id
  availability_zones   = data.aws_availability_zones.all.names

  min_size = 2
  max_size = 2

  dynamic "tag" {
    for_each = var.custom_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_launch_configuration" "example" {
  image_id      = "ami-0d1cd67c26f5fca19"
  instance_type = "t3a.nano"

  lifecycle {
    create_before_destroy = true
  }
}
