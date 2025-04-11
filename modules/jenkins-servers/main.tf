resource "aws_instance" "jenkins-slave-node" {
  #checkov:skip=CKV_AWS_135: Optimazation will be enfored on the stage/production environment
  #checkov:skip=CKV_AWS_126: detailed monitoring will be enfored on the stage/production environment
  #checkov:skip=CKV_AWS_88: using public ip for testing purposes, it will be enfored on the stage/production environment
  ami                         = var.redhat-ami-id
  instance_type               = var.instance-type
  subnet_id                   = var.subnet-id
  key_name                    = var.key-name
  vpc_security_group_ids      = [var.jenkins-sg]
  user_data                   = local.jenkinscript
  associate_public_ip_address = true
  metadata_options {
    http_tokens = "required"
  }
  root_block_device {
    volume_size = 50
    volume_type = "gp3"
    encrypted   = "true"
  }
  tags = {
    Name = "jenkins-slave-node"
  }
}

resource "aws_instance" "jenkins-slave-cloud" {
  #checkov:skip=CKV_AWS_135: Optimazation will be enfored on the stage/production environment
  #checkov:skip=CKV_AWS_126: detailed monitoring will be enfored on the stage/production environment
  #checkov:skip=CKV_AWS_88: using public ip for testing purposes, it will be enfored on the stage/production environment
  ami                         = var.ubuntu-ami-id
  instance_type               = var.instance-type
  subnet_id                   = var.subnet-id
  key_name                    = var.key-name
  vpc_security_group_ids      = [var.jenkins-sg]
  user_data                   = local.jenkins-docker-script
  associate_public_ip_address = true
  metadata_options {
    http_tokens = "required"
  }
  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "jenkins-slave-cloud"
  }
}
