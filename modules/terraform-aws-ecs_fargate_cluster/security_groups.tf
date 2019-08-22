resource "aws_security_group" "lb" {
  name        = "${var.service}-ecs-lb"
  description = "controls access to the LB for ${var.service}"
  vpc_id      = var.vpc_id
  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.common_name} ECS LB"
    },
  )
}

# Seperate out rules so that additional rules can be added from outside of the module without conflict

resource "aws_security_group_rule" "lb_ingress_80" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = [var.env == "stg" ? var.hsv_ingress_cidr : var.public_ingress_cidr]
  security_group_id = aws_security_group.lb.id
}

resource "aws_security_group_rule" "lb_ingress_443" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = [var.env == "stg" ? var.hsv_ingress_cidr : var.public_ingress_cidr]
  security_group_id = aws_security_group.lb.id
}

resource "aws_security_group_rule" "lb_ingress_custom" {
  count = var.service_port != 80 && var.service_port != 443 ? 1 : 0

  type              = "ingress"
  protocol          = "tcp"
  from_port         = var.service_port
  to_port           = var.service_port
  cidr_blocks       = [var.env == "stg" ? var.hsv_ingress_cidr : var.public_ingress_cidr]
  security_group_id = aws_security_group.lb.id
}

resource "aws_security_group_rule" "lb_egress" {
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb.id
}

# Add conditional internal SGs if ALB is internal

data "aws_subnet_ids" "private" {
  vpc_id = var.vpc_id
  tags = {
    VPC = "Private"
  }
}

data "aws_subnet" "private" {
  count = length(var.private_subnets)
  id    = var.private_subnets[count.index]
}

resource "aws_security_group_rule" "lb_ingress_internal" {
  count = var.alb_scheme == "internal" ? 1 : 0

  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = data.aws_subnet.private.*.cidr_block
  security_group_id = aws_security_group.lb.id
}

