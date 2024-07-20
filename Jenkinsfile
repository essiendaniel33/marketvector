pipeline {
    agent any
    parameters {
        string(name: 'BRANCH', defaultValue: 'main', description: 'Pass the name of branch to build from ')
        string(name: 'REPO_URL', defaultValue: 'https://github.com/essiendaniel2013/marketvector.git', description: 'Pass the Repository url to build from ')
        string(name: 'VERSION', description: 'version of docker image to be built, eg. V001 ')
    }
    environment { 
        BRANCH = "${params.BRANCH}"
        REPO_URL = "${params.REPO_URL}"
        VERSION = "${params.VERSION}"
    }
    stages {
        stage('Clone GitHub Repo') {
            steps {
                script {
                    git branch: "${BRANCH}", credentialsId: 'github_creds', url: "${REPO_URL}"
                }
            }
        }
        stage('Building Docker Image') {
            steps {
                script {
                    sh "docker build -t marketvector-html-image ."
                }
            }
        }
        stage('Push To Elastic Container Registry') {
            steps {
                script {
                    sh """
                    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 905418280053.dkr.ecr.us-east-1.amazonaws.com
                    docker tag marketvector-html-image 905418280053.dkr.ecr.us-east-1.amazonaws.com/marketvector-app-repo:${VERSION}
                    docker push 905418280053.dkr.ecr.us-east-1.amazonaws.com/marketvector-app-repo:${VERSION}
                    """
                }
            }
        }
    }
    post {
        success {
            script {
                build job: 'test', parameters: [
                    string(name: 'GITHUB_CREDENTIAL', value: 'github_creds'),
                    string(name: 'GITHUB_REPO_URL', value: 'https://github.com/essiendaniel2013/marketvector.git'),
                    string(name: 'GITHUB_BRANCH', value: 'main'),
                    choice(name: 'TERRAFORM_ACTION', value: 'apply')  // Adjust as needed
                ]
            }
        }
        failure {
            echo 'docker-image failed, not triggering test'
        }
    }
}
