pipeline {
    agent any
    tools {
        terraform 'terraform'
    }
    // environment {
    //       AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
    //       AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    //       AWS_DEFAULT_REGION = 'eu-west-1'
    // }

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
                sh 'terraform plan -var-file="iac.tfvars"'
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
                sh 'terraform ${action} -var-file="iac.tfvars" -auto-approve'
            }
        }
    }
}