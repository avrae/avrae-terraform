output "token_s3_endpoint" {
  value = "https://${aws_s3_bucket.monster_tokens.bucket_domain_name}"
}
