##This module is to be used with ddb_ecs_vpc for now.

locals {
  common_tags = {
    Component   = var.service
    Environment = var.env
    Team        = var.group
  }
}

resource "aws_lb" "internal" {
  count           = var.alb_scheme == "internal" || var.alb_scheme == "internalonly" ? 1 : 0
  name            = "${var.service}-internal-lb"
  subnets         = var.public_subnets
  security_groups = [aws_security_group.lb.id]
  internal        = var.alb_scheme == "internal" ? true : false
  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.common_name} internal ALB"
    },
  )
}

resource "aws_lb" "external" {
  count           = var.alb_scheme == "internalonly" ? 0 : 1
  name            = "${var.service}-external-lb"
  subnets         = var.public_subnets
  security_groups = [aws_security_group.lb.id]
  internal        = false
  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.common_name} external ALB"
    },
  )
}

resource "aws_ecs_cluster" "service_cluster" {
  name = var.cluster_name
  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.common_name} ECS Cluster"
    },
  )
}

