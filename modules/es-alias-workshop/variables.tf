variable "service" {
  description = "Service name of the account"
}

variable "env" {
  description = "Environment name"
}

variable "vpc_id" {
  description = "Default VPC from DDB"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet ids"
}

variable "es_whitelist_sgs" {
  type        = list(string)
  description = "List of security groups to whitelist ElasticSearch access from."
  default     = []
}

