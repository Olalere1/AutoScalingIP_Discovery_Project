resource "aws_instance" "bastion-host" {
  #checkov:skip=CKV_AWS_135: Optimazation will be enfored on the stage/production environment
  #checkov:skip=CKV_AWS_126: detailed monitoring will be enfored on the stage/production environment
  #checkov:skip=CKV_AWS_88: using public ip for testing purposes, it will be enfored on the stage/production environment
  ami                         = var.redhat-ami-id
  instance_type               = var.instance-type
  key_name                    = var.key-name
  vpc_security_group_ids      = var.bastion-sg
  subnet_id                   = var.bastion-subnet
  associate_public_ip_address = true
  user_data          = local.user_data
  metadata_options {
    http_tokens = "required"
  }
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = "true"
  }
  tags = {
    Name = "Bastion-Host"
  }
}
