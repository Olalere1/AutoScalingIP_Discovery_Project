output "bastion-host-ip" {
  value = aws_instance.bastion-host.public_ip
}
