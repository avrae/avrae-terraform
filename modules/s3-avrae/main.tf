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

# lambda pre-deploy bucket
resource "aws_s3_bucket" "lambda_archives" {
  bucket = "${var.s3_prefix}-${var.region}-${var.service}-${var.env}-lambda-archives"
  acl = "private"
  tags = merge(
  local.common_tags,
  {
    "Name" = "${var.service}-lambda-archives"
  })
}

resource "aws_s3_bucket_public_access_block" "lambda_archives" {
  bucket                  = aws_s3_bucket.lambda_archives.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
# ==== VPC ====
# VPC: avrae route tables
data "aws_route_tables" "avrae_route_tables" {
  vpc_id = var.vpc_id

  filter {
    name = "association.subnet-id"
    values = var.subnet_ids
  }
}

# VPC: S3 gateway endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id = var.vpc_id
  service_name = "com.amazonaws.${var.region}.s3"
  route_table_ids = data.aws_route_tables.avrae_route_tables.ids
}
