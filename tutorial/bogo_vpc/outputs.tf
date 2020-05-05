output "ip" {
  description = "Public IP address assigned to the instance"
  value       = aws_instance.terra-sample0.*.public_ip
}