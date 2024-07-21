output "lb_hostname" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}
output "target_group_arn" {
  value = aws_lb_target_group.main.arn
}

output "security_group_id" {
  value = aws_security_group.ecs.id
}
