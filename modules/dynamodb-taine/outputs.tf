output "reports_dynamodb_table_arn" {
  value = "${aws_dynamodb_table.reports_dynamodb_table.arn}"
}

output "reportnums_dynamodb_table_arn" {
  value = "${aws_dynamodb_table.reportnums_dynamodb_table.arn}"
}

output "dynamodb_iam_policy_arn" {
  value = "${aws_iam_policy.dynamo_iam_policy.arn}"
}
