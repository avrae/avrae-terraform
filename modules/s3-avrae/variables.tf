variable "service" {
  description = "Service name of the account"
}

variable "env" {
  description = "Environment name"
}

variable "region" {
  description = "AWS region"
}

variable "vpc_id" {
  description = "ID of the VPC to allow S3 access from"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet ids"
}


variable "s3_prefix" {
  description = "S3 bucket prefix"
}
