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
# VPC: S3 gateway endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id = var.vpc_id
  service_name = "com.amazonaws.${var.region}.s3"
}

# VPC: route table routes to S3
data "aws_route_table" "avrae_subnet_route_table" {
  for_each = var.subnet_ids
  subnet_id = each.value
}

# VPC endpoint -> route table association
resource "aws_vpc_endpoint_route_table_association" "avrae_s3_route_table_assoc" {
  route_table_id = data.aws_route_table.avrae_subnet_route_table.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}
