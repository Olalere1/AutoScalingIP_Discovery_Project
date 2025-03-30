# Installing Jenkins-docker on an ubuntu server
locals {
  jenkins-docker-script = <<-EOF
#!/bin/bash
sudo -i
#install docker
apt update
apt install gnupg2 pass -y
apt install docker.io -y
#ser to Docker group
usermod -aG docker $USER
newgrp docker
hostnamectl set-hostname Docker
#to run at startup
systemctl start docker
systemctl enable docker
systemctl status docker
sed -i  -e '14aExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:4243' -e '14d' /lib/systemd/system/docker.service
systemctl daemon-reload
service docker restart
git clone https://github.com/VictorA07/docker-jenkins-slave.git; cd docker-jenkins-slave        # Observe the cloning of an external public git - Olalere
docker build -t my-jenkins-slave .
sudo chmod 777 /var/run/docker.sock

sudo systemctl restart docker

curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash && sudo NEW_RELIC_API_KEY="${var.nr-key}" NEW_RELIC_ACCOUNT_ID="${var.nr-acc-id}" NEW_RELIC_REGION="${var.nr-region}" /usr/local/bin/newrelic install -y

sudo hostnamectl set-hostname jenkins-docker
EOF  
}

######
# sudo cat <<EOT>> /etc/docker/daemon.json

# {
#   "insecure-registries" : ["${var.nexus-ip}:8085"]
# }
# EOT