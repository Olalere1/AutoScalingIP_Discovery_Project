# Create Ansible Server (EC2 Instance)
resource "aws_instance" "ansible-server" {
  #checkov:skip=CKV_AWS_135: Optimazation will be enfored on the stage/production environment
  #checkov:skip=CKV_AWS_126: detailed monitoring will be enfored on the stage/production environment
  #checkov:skip=CKV_AWS_273: Access  control  will be enfored on the stage/production environment
  ami                    = var.redhat-ami-id
  instance_type          = var.instance-type
  key_name               = var.ssh-key-name
  vpc_security_group_ids = [var.ansible-sg]
  subnet_id              = var.public-subnet-id

  user_data = local.ansible-user-data
  metadata_options {
    http_tokens = "required"
  }
  root_block_device {
    volume_size = 40
    volume_type = "gp3"
    encrypted   = "true"
  }
  tags = {
    Name = "AnsibleServer"
  }
}
