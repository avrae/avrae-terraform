variable "region" {
  description = "AWS region"
}

variable "env" {
  description = "Environment name"
}

variable "service" {
  description = "Service name of the account"
}

variable "group" {
  description = "Group name of the account"
}

variable "account_id" {
  description = "Account ID of this account"
}

variable "common_name" {
  description = "Used as a more readable name for the service"
}

variable "mongodb_username" {
  description = "MongoDB username"
}

variable "mongodb_password" {
  description = "MongoDB password"
}

variable "discord_owner_id" {
  description = "Discord User ID of the owner of the Avrae bot"
}

variable "dicecloud_username" {
  description = "Dicecloud username of the Avrae bot"
}

variable "whitelist_cidrs" {
  type        = list(string)
  description = "IP CIDRs to whitelist globally"
}

variable "dev_access_pubkey" {
  description = "SSH public key to access EC2 instance to access mongo"
}

variable "cert_domain" {
  description = "Used for defining the domain used for the certificate which is used on the load balancer."
  default     = "*.dndbeyond.com"
}

variable "network_range" {
  description = "Used to specify the network range we use, ie 192.168.0.0/16"
}

variable "s3_prefix" {
  description = "Used as a common prefix for service S3 buckets"
}

variable "entitlements_user_dynamo_table" {
  description = "The name of the DynamoDB user entitlement table to grant Avrae read access to"
}

variable "entitlements_entity_dynamo_table" {
  description = "The name of the DynamoDB entity entitlement table to grant Avrae read access to"
}

variable "entitlements_dynamo_table_prefix" {
  description = "Prefix of the tables to grant DynamoDB read access to."
  type        = string
}

variable "auth_service_url" {
  description = "URL of the auth service endpoint to hit."
}
