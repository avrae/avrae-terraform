output "target_group_id" {
  value = aws_lb_target_group.main_target_group.id
}

output "security_group_id" {
  value = aws_security_group.ecs_tasks.id
}

