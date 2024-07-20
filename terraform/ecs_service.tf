provider "aws" {
  region = "us-east-1"
}

resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
}

resource "aws_security_group" "ecs" {
  name_prefix = "ecs-sg-"
  description = "ECS security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "main" {
  name               = "ecs-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "main" {
  name        = "ecs-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
[ec2-user@ip-172-31-95-100 terraform]$ ls
backend.tf      main.tf    task_definition.tf  terraform.tfstate.backup
ecs_service.tf  output.tf  terraform.tfstate   variables.tf
[ec2-user@ip-172-31-95-100 terraform]$ cat backend.tf 
terraform {
  backend "s3" {
    bucket         = "marketvector-s3-bucket"
    key            = "terraform_statefile"   
    region         = "us-east-1"
    dynamodb_table = "marketvector-dynamodb" 
  }
}i
[ec2-user@ip-172-31-95-100 terraform]$ cat task_definition.tf 
resource "aws_ecs_task_definition" "oxer_app" {
  family                   = "oxer-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "oxer-app"
      image     = "905418280053.dkr.ecr.us-east-1.amazonaws.com/marketvector-app-repo:v001"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/new-app"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
[ec2-user@ip-172-31-95-100 terraform]$ ls
backend.tf      main.tf    task_definition.tf  terraform.tfstate.backup
ecs_service.tf  output.tf  terraform.tfstate   variables.tf
[ec2-user@ip-172-31-95-100 terraform]$ cat ecs_service.tf 
resource "aws_ecs_service" "marketvector_app" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.marketvector_app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.ecs.id]       
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn     
    container_name   = "marketvector-app"
    container_port   = var.container_port
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  depends_on = [aws_lb_listener.http]

}
