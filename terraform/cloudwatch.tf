resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/test-app"        
  retention_in_days = 30
}
