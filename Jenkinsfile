pipeline {
    agent any
    parameters {
        string(name: 'BRANCH', defaultValue: 'main', description: 'Pass the name of branch to build from')
        string(name: 'REPO_URL', defaultValue: 'https://github.com/essiendaniel2013/marketvector.git', description: 'Pass the Repository URL to build from')
        string(name: 'VERSION', defaultValue: "${BUILD_ID}" description: 'Version of Docker image to be built, e.g., V001')
    }
    environment {
        AWS_REGION = 'us-east-1'
        BRANCH = "${params.BRANCH}"
        REPO_URL = "${params.REPO_URL}"
        VERSION = "${params.VERSION}"
        TASK_DEF_JSON = 'json/task-def.json'
        ECS_SERVICE_JSON = 'json/ecs-service.json'
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
                    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin 905418280053.dkr.ecr.${AWS_REGION}.amazonaws.com
                    docker tag marketvector-html-image 905418280053.dkr.ecr.${AWS_REGION}.amazonaws.com/marketvector-app-repo:${VERSION}
                    docker push 905418280053.dkr.ecr.${AWS_REGION}.amazonaws.com/marketvector-app-repo:${VERSION}
                    """
                }
            }
        }
        stage('Register Task Definition') {
            steps {
                script {
                    def taskDefArn = sh(script: """
                        aws ecs register-task-definition --cli-input-json file://${TASK_DEF_JSON} --region ${AWS_REGION} --query 'taskDefinition.taskDefinitionArn' --output text
                    """, returnStdout: true).trim()

                    echo "Task Definition ARN: ${taskDefArn}"

                    def ecsServiceJson = readFile(file: ECS_SERVICE_JSON)
                    ecsServiceJson = ecsServiceJson.replaceAll(/"taskDefinition": "arn:aws:ecs:[^"]+"/, "\"taskDefinition\": \"${taskDefArn}\"")
                    writeFile(file: ECS_SERVICE_JSON, text: ecsServiceJson)
                }
            }
        }
        stage('Stop all running tasks') {
            steps {
                script {
                    sh '''
                    tasks=$(aws ecs list-tasks --cluster marketvector-ecs-cluster --service-name marketvector-ecs-service --desired-status RUNNING --query taskArns --output text)
                    for task in $tasks; do
                        aws ecs stop-task --cluster marketvector-ecs-cluster --task $task
                    done
                    '''
                }
            }
        }
        stage('Update ECS Service') {
            steps {
                script {
                    sh "aws ecs update-service --cli-input-json file://${ECS_SERVICE_JSON} --region ${AWS_REGION}"
                }
            }
        }
    }
}
