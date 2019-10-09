output "security_group_id" {
  value = aws_security_group.analytics_dms_access.id
}

output "lambda_security_group_id" {
  value = aws_security_group.analytics_daily_lambda.id
}