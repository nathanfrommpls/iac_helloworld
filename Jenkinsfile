pipeline {
    agent any
    options {
        timeout(time: 1, unit: 'HOURS') 
    }
    triggers {
        pollSCM('H/10 * * * *') 
    }

    stages {
        stage('plan') {
            steps {
                sh '''
                terraform init
                terraform plan -out ${BUILD_TAG}.plan
                '''
            }
        }

        stage('approval') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    input 'Approve terraform apply?'
                }
            }
        }

        stage('apply') {
            steps {
                sh '''
                terraform apply ${BUILD_TAG}.plan
                '''
            }
        }
    }
}
