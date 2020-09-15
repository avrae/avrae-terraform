locals {
  common_tags = {
    Component = var.service
    Environment = var.env
  }
}

# ==== S3 Buckets ====
# monster token bucket
resource "aws_s3_bucket" "monster_tokens" {
  bucket = "${var.s3_prefix}-${var.region}-${var.service}-${var.env}-monster-tokens"
  acl = "private"
  # https://docs.aws.amazon.com/AmazonS3/latest/dev/example-bucket-policies-vpc-endpoint.html#example-bucket-policies-restrict-access-vpc
  # allows access from the avrae vpc
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "avrae-vpc-access",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Effect": "Allow",
      "Resource": ["arn:aws:s3:::${var.s3_prefix}-${var.region}-${var.service}-${var.env}-monster-tokens",
                   "arn:aws:s3:::${var.s3_prefix}-${var.region}-${var.service}-${var.env}-monster-tokens/*"],
      "Condition": {
        "StringEquals": {
          "aws:SourceVpc": "${var.vpc_id}"
        }
      }
    }
  ]
}
POLICY

  tags = merge(
  local.common_tags,
  {
    "Name" = "${var.service}-monster-tokens"
  },
  )
}

# ==== VPC ====
# Security Group: S3 Endpoint
resource "aws_security_group" "tokens_s3" {
  name = "${var.service}-${var.env}-s3-access"
  description = "Security group attached to Avrae S3 gateway endpoint"
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.service}-${var.env} S3 Gateway Endpoint Access"
    env = var.env
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_groups = var.whitelist_sgs
  }
}

# VPC: S3 gateway endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id = var.vpc_id
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  security_group_ids = [
    aws_security_group.tokens_s3.id,
  ]

  private_dns_enabled = true
}
