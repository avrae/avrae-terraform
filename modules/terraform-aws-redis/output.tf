output "hostname" {
  value = aws_elasticache_replication_group.default.primary_endpoint_address
}

output "ec2_redis_default" {
  value = aws_security_group.ec2_redis_default.id
}

