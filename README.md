
![image](https://github.com/user-attachments/assets/3fd22c52-f6a8-4b6b-80ba-cb75e157d41d)


# 24th-March-auto-discovery-project - Independent assessment
# To be added to jenkins master server after infrastructure provisioning
<!-- #sudo cat <<EOT>> /etc/docker/daemon.json
{
  "insecure-registries" : ["${var.nexus-ip}:8085"]
}
EOT -->


Step 1: 
- Set up Jenkins and Vault Server
  <!-- Install necessary plugins to extend jenkins functionalities
    Docker, Sonarqube scanner, Slack, maven-integratio, pipeline stage view, terraform, nexus artifact uploader, owaps, owaps zap
   -->

- Initialise vault and store database credentials
- Setup jenkins, create node and copy the jenkins node commands.

Step 2:

- Update the jenkins node terraform userdata with the jenkins node commands
- Update your vault token
- Update your vpc and subnet ids

Step 3:
Push your update to the repo


Variables are in the iac.tfvars


