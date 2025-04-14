pipeline {
    agent any
    tools {
        terraform 'terraform'
    }
    environment {
          AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
          AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
          AWS_DEFAULT_REGION = 'eu-west-1'
          IAC_VARS_FILE = credentials('iac-tfvars')
    }

    stages {
        stage ('terraform init') {
            steps {
                sh 'terraform init'
            }
        }
        stage ('terraform fmt') {
            steps {
                sh 'terraform fmt -recursive'
            }
        }
        stage ('terraform validate') {
            steps {
                sh 'terraform validate'
            }
        }
        stage ('terraform plan') {
            steps {
                withCredentials([file(credentialsId: 'iac-tfvars', variable: 'IAC_VARS_FILE')]) {
                  sh 'terraform plan -var-file=$IAC_VARS_FILE'
                }
            }
        }
        stage('Request Approval to apply') {
            steps {
                timeout(activity: true, time: 5) {
                    input message: 'Needs Approval to Apply ', submitter: 'admin'
                }
            }
        }
        stage('terraform action') {
            steps {
                withCredentials([file(credentialsId: 'iac-tfvars', variable: 'IAC_VARS_FILE')]) {
                  sh """
                    terraform ${action} -var-file=\$IAC_VARS_FILE -auto-approve
                  """ 
                }
            }
        }
    }
}