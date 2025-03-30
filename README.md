# March 2025 Client Deliverables; AutoScaling Group IP address discovery by Ansible server

![image](https://github.com/user-attachments/assets/3fd22c52-f6a8-4b6b-80ba-cb75e157d41d)


# Important Note:- To be added to jenkins master server after infrastructure provisioning
<!-- #sudo cat <<EOT>> /etc/docker/daemon.json
{
  "insecure-registries" : ["${var.nexus-ip}:8085"]
}
EOT -->


Step 1: 
- Set up Jenkins and Vault Server using parameterised terraform scripts
  <!-- Install necessary plugins to extend jenkins functionalities
    Docker, ssh agent, Sonarqube scanner, Slack, maven-integration, pipeline stage view, terraform, nexus artifact uploader, owaps depenpency, owaps zap
    Also configure terraform in the Jenkins tools
   -->

- Initialise vault and store database credentials
<!-- vault operator init; vault login; vault secrets enable -path=secret/kv; vault kv put secret/database username=petclinic password=petclinic
-->

- Create infrastructure (Infra) pipeline ensuring it is parameterised.

- Setup jenkins
<!-- Among other steps, check and download SSH keypair from Jenkins web interphase workspace, then add keypair to Jenkins global credentials.
--> 

- create Jenkins node from Jenkins master server and copy the jenkins node commands.
<!-- using private IP of Jenkinsslave in the host
-->


Step 2:

- Update the jenkins node terraform userdata (i.e. in jenkinscript.tf line 50-52) with the jenkins node commands
- Update the vault token (i.e. in the provider.tf)
- Update your vpc and subnet ids (i.e. in the root main.tf)


Step 3:
Push your update to the repo

Step 4: 

- Create Jenkins cloud same from the Jenkins master server
<!--
Pick image built name from user_data of jenkins-docker.tf (line 22)
Pull strategy - "never"
Connect method - "SSH"
SSH key - "use configured credentials
create (new) SSH credentials and select in drop down.
-->

- Test Jenkins cloud with new pipeline using the default "Hello world" scripts and changing agent label accordingly;
<!-- agent {
        label "jenkins-cloud"
}
-->

Step 5:
- Setup nexus web interpase
<!-- 
SSH into nexus server
Click sign in on the web interphase

cat pop-up directory on the web interphase onto nexus cli to copy password; username=admin
change password; 

set up 2 repository (1. Maven - for nexus repo; 2. Docker - for docker repo)

maven2hosted; release -"Mixed"
Deployment policy - "allow redeploy"
Docker hosted; http-> Enter docker second port (8085), Enable VI API
Realms; click and save "Docker Bearer Token"
-->

- Setup Sonarqube server from the web interphase
<!--
Admin & Admin (==> Admin123)
Setup webhook between sonarqube & Jenkins; Administration -> configuration -> webhook -> https://jenkins url/sonarqube-webhook/
Security -> user -> tokens -> generate tokens
create credentials on Jenkins (secret text) with the token
-->

Step 6:
- Create more credentials on Jenkins for seamless authentication and reference as environment variable in pipeline scripts
<!--
secret text; Ansible IP address (N/B: Private IP)
secret text: NVD Key (for OWASP API Key)
secret text: Slack cred;
  -- Add Apps -> Jenkins CI -> Configuration -> Add to slack -> Add channel -> copy token to use on Jenkins credential setup

password; Nexus-cred =>admin/admin123
secret text; nexus-username => admin
secret text; nexus-password => admin123
secret text; nexus-repo => copy nexus-ip:8085 (use the real IP I suppose! not sure though!)
-->

- Complete the configuration of Jenkins tools
<!--
Set up JDK (Do "mvn -version" on Jenkins cli server to get "JAVA_HOME" info)
Maven installations (Copy for "MAVEN-Home" on cli server)

Dependency-check; Click on install automatically and select Github
Sonarqube; check Environment variable, fill Server URL, and authentication token

Slack; workspace name, Credentials, Channel name => test connection
-->

Step 7:
- Go to application.properties file and change database endpoint (if need be and authentication username/password)
<!--
The lastest rds-endpoint can be obtained from the Console output of the infrastructure pipeline job
-->

- Make necessary edits on the Jenkinsfile to be used for application deployment

- Build new pipeline job for application deployment
<!--
You can use any name for your pipeline (Pet-adoption)
use EUteam25 branch of the US team Git repo as the Git SCM for your application pipeline build job!
-->


N/B: Variables and sensitive information are in the iac.tfvars and as such passed into .gitignore!


