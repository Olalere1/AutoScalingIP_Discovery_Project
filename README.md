# March 2025 Client Deliverables; AutoScaling Group IP address discovery by Ansible server

![image](https://github.com/user-attachments/assets/3fd22c52-f6a8-4b6b-80ba-cb75e157d41d)


# Important Note:- To be added to jenkins master server after infrastructure provisioning
<!-- #sudo cat <<EOT>> /etc/docker/daemon.json
{
  "insecure-registries" : ["${var.nexus-ip}:8085"]
}
EOT -->


Step 1: 
- Set up Jenkins and Vault Server, S3 bucket and DynamoDB table for state code managment using script create-s3.sh (manually on terminal)
  <!-- 
  - From the main directory do sh create-s3.sh to provision jenkins and vault server

  Install necessary plugins to extend jenkins functionalities
  Docker(commons, pipeline, API,...), ssh agent, Sonarqube scanner, Slack, maven-integration, pipeline stage view, terraform, nexus artifact uploader, owaps depenpency, owaps zap, git, github, (git client)

   -  Also configure terraform in the Jenkins tools
   -  Not necessary, already in user-data script: Configure Docker in the Jenkins tools also (name=docker, install automatically=from docker.com, download=latest)

   - In the system settings, configure terraform - install automatically, version (50312 linux - amd64)

   -->

- Initialise vault and store database credentials
<!-- 
- cd into jenkins-vault_server & ssh into the vault server (IP can be found on main.tf also) using the vault-pri-key.pem created.
- Then do vault operator init; vault login; vault secrets enable -path=secret/kv; vault kv put secret/database username=petclinic password=petclinic (copy out the vault token to be updated in provider.tf script)
-->

- Create infrastructure (Infra) pipeline    
<!--
using 1st Jenkinsfile with terraform script (init,fmt,validate, plan, approval, $action) - click lightweight checkout
Ensuring it is parameterised (action - apply/destroy) - 

Not sure though: #You might need to comment out the profile in backend.tf and provider.tf during infra-pipeline build!
-->

- Setup jenkins
<!-- 
- Add your git account in credentials (username with password - as kind, use git-token in the password space, ID:git-cred)

- Set up git SCM for the infra pipeline, use jenkinsfile with terraform steps and build.

- Among other steps, check and download SSH keypair from Jenkins infra-pipeline workspace directory, save/replace in local repo, then also give permission using the chmod 400 .pem, (thereafter add keypair to Jenkins global credentials). (This can be done from the cli command as well by ssh into Master server and go to workspace directory)

- Duplicate cli terminal and SSH into jenkins node server using keypair from workspace, check jenkins node ip from console output for ssh purposes -> ssh -i .pem ec2-user@jenkins-node-IP; then exit

- DNS name: jenkins.hullerdata.com (N/B)
--> 

- create Jenkins node connection on Jenkins master server and copy the jenkins node commands.    
<!-- 
Create (new) SSH credentials -using SSH username with private key selection, among other settings paste private key of the slave instance (cat ...pem to get)!

Return back to managed jenkins - nodes- and create the node; type=permanent agent, name= to be used can be found in the jenkinscript.tf (for node)
Number of executors = 1
remote root directory = /opt/build
label=(should be same as node agent specified on jenkinsfile)
usage=as much as possible
launch method = via SSH
under Host, add the private IP of the slave node and select the SSH credential created earlier
Host key verification strategy: Manually trusted .....
Availability: keep this agent online as much as possible

SAVE
Then click on jenkins-node created, you will see some commands, copy the appropriate one -                                  
-->


Step 2:
- Update the jenkins node terraform userdata (i.e. in jenkinscript.tf line 50 and 52) with the jenkins node commands
<!--
/Ensuring you also use current master jenkins ip address in both lines 50 and 52/
SSH into the jenkins node public Ip server (details can be found from the console output of the infra-pipeline),

run line 50 command on the cli terminal, followed by 51 and 52 (A connected output should be revealed in the cli terminal)
-->

- Update the vault token (i.e. in the provider.tf)
<!--
- Update your vpc and subnet ids (i.e. in the root main.tf) - The last command in the create-s3.sh automatically does this though!
-->
- Review the root main.tf script and change all relevant information that need to be updated as per deployed infrastructure.


Step 3:
Push your update to the repo


Step 4: 
- Create Jenkins cloud from the manage jenkins/cloud of the Jenkins master server
<!--
(Don't bother on this, already in userdata script -> SSH using infra pem, into jenkins cloud (ubuntu) and do sudo hostnamectl to set-hostname to jenkins-cloud, before exiting; Do same for jenkins node (ec2-user)!)

name=docker-slave (or jenkins-cloud); click Docker Cloud details and configure;
docker host uri: tcp://check console output for jenkins cloud public IP:port number(4243)
server credentials - Create a credential on Jenkins using username and password (Jenkins/password), ID: docker-cred (to be used below later)
click enabled; test connection

click=> Docker Agent template -> Add Docker template;
label=docker-slave (or jenkins-slave)
click Enabled
Name=docker-slave  (or jenkins-slave)
Docker Image = Pick image built name from user_data of jenkins-docker.tf (line 22) or SSH into Jenkins docker slave and do "docker image ls" to get image name!
Remote File System Root = /home/jenkins
Pull strategy - "never pull"
Connect method - "connect with SSH"
#server credentials - Create a credential on Jenkins using username and password (Jenkins/password), ID: docker-cred.
SSH key - "use configured SSH credentials (and select appropriate jenkins credential in the dropdown)
Host key verification strategy: Non verifying

AND SAVE
-->

- Test Jenkins cloud with new pipeline job (test) using the default "Hello world" scripts and changing agent label accordingly;
<!-- 
pipeline {
        agent {
           label "jenkins-cloud"
        }
        stages {
            stage('Hello') {
               steps {
                  echo 'Hello World'
               }
            }
        }
    }

click also use Groovy Sandbox
And Build

And using same pipeline job and script, with only changing of agent label to "jenkins-node", test the second slave;
pipeline {
        agent {
           label "jenkins-node"
        }
        stages {
            stage('Hello') {
               steps {
                  echo 'Hello World'
               }
            }
        }
    }

-->

Step 5:
- Setup nexus through the DNS name web interpase
<!-- 
DNS name: nexus.hullerdata.com (N/B)
SSH into nexus server on the CLI
Click sign in on the web interphase of the nexus server

cat pop-up directory of the web interphase onto nexus cli to copy password; username=admin
change password; => admin123 (disable anonymous access!)
-->

- On nexus web server, create 2 repository (1. Maven - named as nexus-repo; 2. Docker - named as docker-repo)
<!--
From the settings icon!
maven2hosted; version policy - "Mixed"
Deployment policy - "allow redeploy"
Docker hosted; http-> Enter docker second port (8085), Enable VI API
Realms; click and save "Docker Bearer Token"
-->

- Setup Sonarqube server from the through the DNS name web interphase
<!--
DNS name: sonarqube.hullerdata.com (N/B)
admin & admin (==> new password = admin123)
Setup webhook between sonarqube & Jenkins; Administration -> configuration -> webhook -> https://jenkins DNS url - hullerdata/sonarqube-webhook/
Security -> user -> tokens -> generate tokens
create credentials (sonar-cred) on Jenkins (secret text) with the token
-->

Step 6:
- Create more credentials on Jenkins for seamless authentication and reference as environment variable in pipeline scripts
<!--

secret text; ansible-ip (N/B: Private IP, can be gotten from jenkins console output or your AWS console page)
secret text: nvd-key (for OWASP API Key)
secret text: from slack, copy channel name and use as secret (ID: slack-channel)

secret text: slack-cred;
  -- On desired slack channel, scroll down on the left to Add Apps -> Jenkins CI -> Configuration -> Add to slack -> choose a channel -> Add JenkinsCI integration -> scroll down and copy token to use on Jenkins credential setup

password; admin/admin123 => Nexus-cred
secret text; admin => nexus-username
secret text; admin123 => nexus-password

secret text; from jenkins console output, get nexus public IP:8085 and use (ID:nexus-repo) 
secret text; set up credentials for private infrastructure SSH key to be used by ansible in pipeline to deploy to stage and production [ID:ansible-key]

password; username(jenkins)/password() to jenkins server I suppose! (ID: jenkins-pass)        #Unresolved!
-->

- Complete the configuration of Jenkins systems in the Managed Jenkins
<!--
Sonarqube; (name: sonarqube) check Environment variable, fill Server URL, and authentication token
Slack; workspace name (Cloudhight), Credentials (slack-cred), Default channel/Member ID (Channel name) => test click connection
-->

- Complete the configuration of Jenkins tools in the Managed Jenkins
<!--
SSH into the jenkins-slave node on the cli and do mvn -v

Set up JDK (name -java) - copy java-version details on cli into "JAVA_HOME" on jenkins JDK tools - uninstall automatically.
Maven installations (name -maven) - Copy for "MAVEN_Home" on cli server.

Dependency-Check (name -> DP-Check); Click on install automatically and select Github
-->

- Configuring jenkins to talk to nexus server (for artifact & image upload)
<!--
1) SSH into the jenkins master server ?using the vault-pri-key....created? (first cd into jenkins-vault_server folder), text edit /etc/docker/daemon.json, and add this from the jenkins-docker.tf script - this makes it possible to use master jenkins to deploy on nexus!

{
   "insecure-registries" : [actual nexus public IP obtainable from console output:8085"]
}

On same CLI run:
     sudo systemctl daemon-reload 
     sudo systemctl restart docker

2) Repeat same step for Jenkins node! (Actually ignore this step since the user_data script is doing this for the node slave in the set up and no need to manually add)
-->

Step 7:
- Change new-relic lience keys on dockerfile and new-relic.yml script
- Go to application.properties file and change database endpoint (if need be and authentication username/password)
<!--
The lastest rds-endpoint can be obtained from the Console output of the infrastructure pipeline job
-->

- Make necessary edits on the Jenkinsfile to be used for application deployment

- Build new pipeline job for application deployment
<!--
You can use any name for your pipeline (Pet-adoption)
use Olalere1-present branch of the US team Git repo as the Git SCM for your application pipeline build job!

Hardcode slack channel name (instead of using variable - $SLACK_CHANNEL) with specific channel to be used in the jenkinsfile, if slack notification fails in pipeline build.

echo “${var.private-key-name}” >> /home/ec2-user/.ssh/id_rsa; you might be having challenge ssh-ing from Baston host server to Ansible, that maybe if the key is not copied in the script to the id_rsa; as such you will have to copy it over manually using the text editor (vi)

Troubleshooting note: Always remember to ssh into a server, a check (cat) or edit (vi) script and then rerun (sh). Using this (cat /var/log/cloud-init-output.log) also to troubleshoot instance with running container might help.

Troubleshooting note: Also possibility of checking things manually on your AWS console to fix like - subnet, security group, picking IP address etc
-->

- Monitor infrastructures and application deployed on New relic
<!--
On new relic web interface, go to All Entities - Hosts - click specific infrastructure to see dashboard
On new relic web interface, go to All Entities - Services (APM) - click specific application deployed, to see dashboard.
-->

Step 8: 
- Always remember to destroy provisioned infrastructure to avoid excessive billing.


Step 9: 
- Challenges Encountered and Solutions Implemented

1. In the infrastructure destroy script, Terraform remote backend was always destroyed before the infrastructure destroy commences/completes - meaning I ended up later having to manually destroy turns of infrastructure. To navigate through this challenge, I added a Sleep command and Checks to ensure infrastructure complete destruction before proceeding to remote state backend clean up and confirmation to that.

2. There are situations were the instance profile of the servers are not destroyed along with other resources during the automated destroy process. And since no specific location on AWS console for instance profile destruction, creating the servers another time runs into a block, necessitating changing the naming of the instance profile in subsequent server deployment.

<!--
start with running create-s3.sh in main; if instance profile error occur, change the name slightly of the  server instance profile on both vault_iam and jenkins_iam, then cd into Jenkins-vaults_server and run terraform apply -auto-approve manually on the terminal. 
-->





N/B: Variables and sensitive information are in the iac.tfvars and as such passed into .gitignore!


