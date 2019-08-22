resource "aws_security_group" "redis_redis_default" {
  name        = "redis-${var.service}-${var.env}" #"redis-${var.name}-self-sg"
  description = "Security group attached to redis."
  vpc_id      = var.vpc_id
  tags = merge(
    local.common_tags,
    {
      "Name" = "Redis SG ${var.common_name}"
    },
  )

  ingress {
    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"
    # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
    # force an interpolation expression to be interpreted as a list by wrapping it
    # in an extra set of list brackets. That form was supported for compatibilty in
    # v0.11, but is no longer supported in Terraform v0.12.
    #
    # If the expression in the following list itself returns a list, remove the
    # brackets to avoid interpretation as a list of lists. If the expression
    # returns a single list item then leave it as-is and remove this TODO comment.
    security_groups = concat(
      var.redis_whitelist_sgs,
      list("${aws_security_group.ec2_redis_default.id}"),
    )
    cidr_blocks = var.redis_whitelist_cidrs
  }
}

resource "aws_security_group" "ec2_redis_default" {
  name        = "ec2-redis-${var.service}-${var.env}" #"redis-${var.name}-ec2-sg"
  description = "Security group for ec2 access to redis."
  vpc_id      = var.vpc_id
  tags = merge(
    local.common_tags,
    {
      "Name" = "EC2 Redis ${var.common_name}"
    },
  )
}

resource "aws_security_group_rule" "es_whitelist_cidr" {
  # This errors if cidr_blocks is an empty arrray so skip this in that case
  count       = length(var.redis_whitelist_cidrs) == 0 ? 0 : 1
  type        = "ingress"
  from_port   = 6379
  to_port     = 6379
  protocol    = "tcp"
  cidr_blocks = var.redis_whitelist_cidrs

  security_group_id = aws_security_group.ec2_redis_default.id
}

resource "aws_security_group_rule" "es_whitelist_sgs" {
  count                    = length(var.redis_whitelist_sgs) #"${var.num_redis_whitelist_sgs}"
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = element(var.redis_whitelist_sgs, count.index)

  security_group_id = aws_security_group.ec2_redis_default.id
}

