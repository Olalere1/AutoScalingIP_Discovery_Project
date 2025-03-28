locals {
  user_data = <<-EOF
    #!/bin/bash
    echo "Copying private key..."
    echo “${var.private-key-name}” >> /home/ec2-user/.ssh/id_rsa
    sudo chmod 400 /home/ec2-user/.ssh/id_rsa
    sudo chown ec2-user:ec2-user /home/ec2-user/.ssh/id_rsa

    curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash && sudo NEW_RELIC_API_KEY="${var.nr-key}" NEW_RELIC_ACCOUNT_ID="${var.nr-acc-id}" NEW_RELIC_REGION="${var.nr-region}" /usr/local/bin/newrelic install -y
  EOF
}

