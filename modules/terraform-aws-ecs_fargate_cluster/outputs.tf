##Used for Cloudflare DNS Entry
output "lb_external_dns" {
  value = aws_lb.external[0].dns_name
}

output "lb_internal_dns" {
  value = aws_lb.internal[0].dns_name
}

##Used for Route53
output "lb_external_dns_zone_id" {
  value = aws_lb.external[0].zone_id
}

output "lb_internal_dns_zone_id" {
  value = aws_lb.internal[0].zone_id
}

output "lb_external_listener" {
  value = aws_lb.external[0].id
}

output "lb_internal_listener" {
  value = aws_lb.internal[0].id
}

output "ecs_lb_sg" {
  value = aws_security_group.lb.id
}

output "lb_external_suffix" {
  value = aws_lb.external[0].arn_suffix
}

output "lb_internal_suffix" {
  value = aws_lb.internal[0].arn_suffix
}

output "cluster_name" {
  value = aws_ecs_cluster.service_cluster.name
}

output "cluster_id" {
  value = aws_ecs_cluster.service_cluster.id
}

output "lb_sg_id" {
  value = aws_security_group.lb.id
}

