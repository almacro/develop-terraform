output "instance_ip_addresses" {
    value = {
        for instance in aws_instance.server:
            instance.id => instance.private_ip
    }
}