locals {
  common_tags = {
    Component   = var.service
    Environment = var.env
    Team        = var.group
  }
}

resource "aws_elasticache_subnet_group" "default" {
  name       = "${var.service}-elasticache-subnet"
  subnet_ids = var.subnet_ids
}

resource "aws_elasticache_replication_group" "default" {
  replication_group_id          = var.name
  replication_group_description = "Replication Group for ${var.name}-${var.env}-redis"

  #availability_zones            = "${var.availability_zones}" #["us-west-2a", "us-west-2b"]

  engine                     = "redis"
  node_type                  = var.instance_type
  port                       = 6379
  number_cache_clusters      = var.num_dbs
  parameter_group_name       = var.parameter_group_name
  engine_version             = var.engine_version
  snapshot_retention_limit   = var.backup_retention
  snapshot_window            = var.backup_retention == 0 ? "" : var.backup_window
  maintenance_window         = var.maintenance_window
  automatic_failover_enabled = var.automatic_failover
  security_group_ids         = [aws_security_group.redis_redis_default.id]
  snapshot_arns              = var.snapshot_source_arn
  subnet_group_name          = aws_elasticache_subnet_group.default.name
  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.common_name} Redis"
    },
  )

  lifecycle {
    ignore_changes = [engine_version]
  }
}

