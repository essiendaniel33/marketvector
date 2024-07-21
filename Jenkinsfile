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

         stage('Running Task Definition') {
            steps {
                script {
                    dir('json') {
                    sh "aws ecs register-task-definition --cli-input-json file://task-def.json"
                    }
                  }  
                }
              }

         stage('Delete current running ecs service') {
            steps {
                script {
                    dir('json') {
                    sh "aws ecs create-service --cli-input-json file://ecs-service.json"
                    }
                  }
                }
             }   
        
         stage('Deploy new ecs service') {
            steps {
                script {
                    dir('json') {
                    sh "aws ecs create-service --cli-input-json file://ecs-service.json"
                    }
                  }
                }
             }   
    
      }
  }  
