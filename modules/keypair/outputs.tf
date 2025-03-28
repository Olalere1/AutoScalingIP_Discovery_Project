output "infra-private-key" {
  value = tls_private_key.infra-key.private_key_pem
}

output "infra-pub-key" {
  value = aws_key_pair.infra-key-pub.id
}