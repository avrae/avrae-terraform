locals {
  common_tags = {
    Component   = var.service
    Environment = var.env
    Team        = var.group
  }
}

# DynamoDB Table - Reports
resource "aws_dynamodb_table" "reports_dynamodb_table" {
  name           = "taine.reports"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "report_id"
  tags           = local.common_tags

  attribute {
    name = "report_id"
    type = "S"
  }
  attribute {
    name = "message"
    type = "N"
  }
  attribute {
    name = "github_issue"
    type = "N"
  }
  attribute {
    name = "github_repo"
    type = "S"
  }

  global_secondary_index {
    name            = "message_id"
    hash_key        = "message"
    write_capacity  = 10
    read_capacity   = 10
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "github_issue"
    hash_key        = "github_issue"
    range_key       = "github_repo"
    write_capacity  = 10
    read_capacity   = 10
    projection_type = "ALL"
  }
}

# DynamoDB Table - ReportNums
resource "aws_dynamodb_table" "reportnums_dynamodb_table" {
  name           = "taine.reportnums"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "identifier"
  tags           = local.common_tags

  attribute {
    name = "identifier"
    type = "S"
  }
}

# IAM DynamoDB Policy Attachment
resource "aws_iam_policy" "dynamo_iam_policy" {
  name        = "taine-dynamo-policy-${var.env}"
  path        = "/"
  description = "Policy limiting dynamo access for Taine"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "dynamodb:*",
            "Resource": [
                "${aws_dynamodb_table.reports_dynamodb_table.arn}",
                "${aws_dynamodb_table.reports_dynamodb_table.arn}/index/*",
                "${aws_dynamodb_table.reportnums_dynamodb_table.arn}",
                "${aws_dynamodb_table.reportnums_dynamodb_table.arn}/index/*"
            ]
        }
    ]
}
EOF

}

