locals {
  common_tags = {
    Component   = var.service
    Environment = var.env
    Team        = var.group
  }
}

resource "aws_security_group" "mongodb_mongodb_default" {
  name        = "mongodb-${var.service}"
  description = "Security group attached to MongoDB."
  vpc_id      = var.vpc_id
  tags = merge(
    local.common_tags,
    {
      "Name" = "MongoDB SG ${var.common_name}"
    },
  )

  ingress {
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = var.mongodb_whitelist_sgs
  }
}

resource "aws_docdb_subnet_group" "default" {
  name       = "${var.service}-docdb-subnet"
  subnet_ids = var.subnet_ids
  tags       = local.common_tags
}

resource "aws_docdb_cluster" "default" {
  cluster_identifier     = "${var.service}-${var.env}"
  master_username        = var.mongodb_username
  master_password        = var.mongodb_password
  vpc_security_group_ids = [aws_security_group.mongodb_mongodb_default.id]
  db_subnet_group_name   = aws_docdb_subnet_group.default.name
  tags                   = local.common_tags
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = 2
  identifier         = "${var.service}-${var.env}-${count.index}"
  cluster_identifier = aws_docdb_cluster.default.id
  instance_class     = "db.r4.large"
}

