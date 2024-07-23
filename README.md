## AWS ECS Deployment Automation

This project automates the deployment of a static website on AWS ECS using Jenkins for CI/CD. It includes Docker for containerization and Terraform for infrastructure provisioning.

## Overview

- **Jenkins**: CI/CD server running on EC2.
- **Docker**: For building and managing containers.
- **Terraform**: For provisioning infrastructure.
- **AWS Services**: ECR (for Docker images), S3 (for Terraform state), DynamoDB (for state locking), and ECS (for container orchestration).

## Prerequisites

1. **Jenkins Server**:
   - EC2 instance with Jenkins.
   - Installed: Docker, Terraform, Git, and AWS CLI.

   ```bash
   # Update packages and install required software
   sudo apt update && sudo apt upgrade -y
   sudo apt install -y docker.io terraform git awscli

   # Install Jenkins
   wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
   sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
   sudo apt update
   sudo apt install -y jenkins

   # Start Jenkins
   sudo systemctl start jenkins
   sudo systemctl enable jenkins

   # Add Jenkins and current user to Docker group
   sudo usermod -aG docker jenkins
   sudo usermod -aG docker $USER
   ```

2. **AWS Setup**:

   - **Create ECR Repository for Docker Images**:
     ```bash
     aws ecr create-repository --repository-name marketvector-app-repo
     ```

   - **Create S3 Bucket for Terraform State Files**:
     ```bash
     aws s3api create-bucket --bucket my-terraform-state-bucket --region us-east-1
     ```

   - **Create DynamoDB Table for Terraform State Locking**:
     ```bash
     aws dynamodb create-table --table-name terraform-lock --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
     ```

   - **Create IAM Role with Necessary Permissions Attached to the Jenkins Server**:
     1. Sign in to the AWS Management Console and open the IAM console at https://console.aws.amazon.com/iam/.
     2. In the navigation pane, choose **Roles**.
     3. Choose **Create role**.
     4. In the **Create role** page, select **AWS service** and choose **EC2**.
     5. Attach the following policies:
        - **AmazonEC2FullAccess**
        - **AmazonS3FullAccess**
        - **AmazonDynamoDBFullAccess**
        - **AmazonECS_FullAccess**
        - **AmazonECRFullAccess**
        - **AdministratorAccess** (Adjust based on your security requirements)
     6. For **Role name**, enter `jenkins-ec2-role`.
     7. Choose **Create role**.
     8. Navigate to the EC2 console at https://console.aws.amazon.com/ec2/.
     9. Select your Jenkins EC2 instance.
     10. Choose **Actions**, then **Security**, and then **Modify IAM role**.
     11. Select the IAM role (`jenkins-ec2-role`) and attach it to the instance.

3. **GitHub Repository**:
   - Contains Terraform scripts, ECS task and service definitions, application code, and Jenkinsfiles.

   ```bash
   # Navigate to the directory where you want to clone the repository
   cd /path/to/directory

   # Clone the repository
   git clone https://github.com/essiendaniel2013/marketvector.git
   ```

## Setup Instructions

1. **Prepare Jenkins Server**:
   - Launch an EC2 instance.
   - Install Docker, Terraform, Git, and AWS CLI.
   - Configure Jenkins with necessary plugins and credentials.

   ```bash
   # Install Jenkins plugins (via Jenkins UI or script)
   # Recommended plugins: Pipeline, Git, Docker Pipeline, Terraform, AWS Credentials
   ```

2. **AWS Resource Setup**:
   - Create an ECR repository.
   - Create an S3 bucket for Terraform.
   - Create a DynamoDB table for state locking.
   - Create and attach an IAM role to the Jenkins server.

3. **Clone the Git Repository**:
   - Clone the repository that contains Terraform scripts, ECS task and service definitions, application code, and Jenkinsfiles.

   ```bash
   # Navigate to the directory where you want to clone the repository
   cd /path/to/directory

   # Clone the repository
   git clone https://github.com/essiendaniel2013/marketvector.git
   ```

## Deployment Process

1. **Configure Seed Job**:
   - Use the seed job in Jenkins to create two pipelines:
     - **Infrastructure Provision Pipeline**: Sets up ECS cluster, CloudWatch, and related resources.
     - **Deployment Pipeline**: Handles Docker image building, ECR push, ECS task definition registration, and ECS service updates.

2. **Run Infrastructure Pipeline**:
   - Triggers Terraform to provision the required AWS infrastructure.

   ```bash
   # Navigate to Terraform directory and initialize
   cd path/to/terraform
   terraform init

   # Apply the Terraform plan
   terraform apply
   ```

3. **Run Deployment Pipeline**:
   - Builds and pushes the Docker image to ECR.
   - Updates ECS task definition and service.
   - Deploys the application and verifies via the load balancer’s DNS name.

   ```bash
   # Build Docker image
   docker build -t oxer-html-image .

   # Tag Docker image
   docker tag oxer-html-image:latest 905418280053.dkr.ecr.us-east-1.amazonaws.com/marketvector-app-repo:v001

   # Login to ECR
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 905418280053.dkr.ecr.us-east-1.amazonaws.com

   # Push Docker image to ECR
   docker push 905418280053.dkr.ecr.us-east-1.amazonaws.com/marketvector-app-repo:v001
   ```

## Webhook Configuration

- Set up a GitHub webhook to trigger Jenkins pipelines on code updates.

   ```bash
   # In GitHub repository settings, add webhook with Jenkins URL
   # Example: http://your-jenkins-server:8080/github-webhook/
   ```

## Troubleshooting

- **Jenkins Issues**: Check Jenkins logs and AWS credentials.
- **AWS Deployment Issues**: Verify resources in AWS Console and check CloudWatch logs.

## License

This project is licensed under the MIT License.

---

Feel free to modify and expand this README based on your specific requirements and additional details.
