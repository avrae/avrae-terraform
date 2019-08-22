variable "service" {
  description = "Service name of the account"
}

variable "env" {
  description = "Environment name"
}

variable "group" {
  description = "Group name of the account"
}

variable "common_name" {
  description = "Used as a more readable name for the service"
}

variable "vpc_id" {
  description = "Default VPC from DDB"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet ids"
}

variable "mongodb_username" {
  description = "MongoDB username"
}

variable "mongodb_password" {
  description = "MongoDB password"
}

variable "mongodb_whitelist_sgs" {
  type        = list(string)
  description = "List of security groups to whitelist MongoDB access from."
  default     = []
}

