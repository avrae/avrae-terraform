variable "service" {
  description = "Service name of the account"
}

variable "env" {
  description = "Environment name"
}

variable "reports_dynamodb_table_arn" {
  description = "ARN of the Reports DynamoDB table"
}

variable "reportnums_dynamodb_table_arn" {
  description = "ARN of the ReportNums DynamoDB table"
}
