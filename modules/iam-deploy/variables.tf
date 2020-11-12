variable "service" {
  description = "Service name of the account"
}

variable "env" {
  description = "Environment name"
}

variable "account_id" {
  description = "Account ID of this account"
}

variable "region" {
  description = "AWS region"
}

variable "s3_prefix" {
  description = "shared S3 prefix for service buckets"
}
