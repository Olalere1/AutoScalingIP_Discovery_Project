# Create a Key Pair to SSH into EC2 instance
resource "tls_private_key" "infra-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Store the private key locally
resource "local_file" "infra-pri-key" {
  filename        = "infra-pri-key.pem"
  content         = tls_private_key.infra-key.private_key_pem
  file_permission = "600"
}

# Store the public key locally
resource "aws_key_pair" "infra-key-pub" {
  key_name   = "infra-pub-key"
  public_key = tls_private_key.infra-key.public_key_openssh
}