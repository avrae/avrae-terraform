variable "service" {
  description = "Service name of the account"
}

variable "env" {
  description = "Environment name"
}

variable "group" {
  description = "The team responsible"
}

variable "region" {
  description = "AWS region"
}

variable "common_name" {
  description = "Used as a more readable name, ie Monster Service instead of monster-service"
}


variable "s3_prefix" {
  description = "S3 bucket prefix"
}

variable "vpc_id" {
  description = "ID of the VPC"
}

variable "mongo_url_secret_arn" {
  description = "ARN of SecretsManager secret for Mongo"
}