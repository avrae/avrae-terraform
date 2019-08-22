variable "name" {
  description = "Name for this service."
  default     = "default"
}

variable "env" {
  description = "Name of the environment for this account, i.e. stg or live."
}

variable "group" {
  description = "Group that owns this service."
}

variable "service" {
  description = "Name of the service/project for this account."
}

variable "oncall" {
  description = "Oncall email or phone number."
  default     = "it-oncall@curse.com"
}

variable "email" {
  description = "General contact email."
  default     = "it-media@curse.com"
}

variable "additional_sgs" {
  type        = list(string)
  description = "List of additional security groups to attach to EFS."
  default     = []
}

variable "redis_whitelist_sgs" {
  type        = list(string)
  description = "List of security groups to whitelist Redis access from."
  default     = []
}

variable "num_redis_whitelist_sgs" {
  description = "List of security groups to whitelist Redis access from."
  default     = 0
}

variable "redis_whitelist_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks to whitelist Redis access from."
  default     = []
}

variable "automatic_failover" {
  description = "If automatic failover should be enabled (true/false)."
  default     = "false"
}

variable "availability_zones" {
  type    = list(string)
  default = []
}

variable "cluster_parameter_group_name" {
  description = "Name of Cluster DB cluster parameter group to apply."
  default     = "default.redis3.2"
}

variable "parameter_group_name" {
  description = "Name of DB cluster parameter group to apply."
  default     = "default.redis3.2"
}

variable "backup_retention" {
  description = "Snapshot retention in days."
  default     = "1"
}

variable "num_dbs" {
  description = "Number of dbs to create."
}

variable "engine_version" {
  description = "Number of dbs to create."
}

variable "instance_type" {
  description = "RDS Instance type to use."
  default     = "cache.t2.micro"
}

variable "backup_window" {
  description = "Preferred backup window."
  default     = "05:00-07:00"
}

variable "maintenance_window" {
  description = "Maintenance window."
  default     = "tue:07:00-tue:09:00"
}

variable "publicly_accessible" {
  description = "If db should be publicly accessable or not (true/false)"
  default     = "false"
}

variable "snapshot_source_arn" {
  type        = list(string)
  description = "ARN of the rdb file in S3 to restore to. Read access is granted to redis for this object."
  default     = []
}

variable "subnet_ids" {
  type        = list(string)
  description = "list of subnets"
}

variable "vpc_id" {
  type        = string
  description = "ID of VPC."
}

variable "common_name" {
  description = "Used as a more readable name for the service"
}

