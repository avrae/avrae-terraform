variable "env" {
}

variable "service" {
}

variable "account_id" {
}

variable "region" {
}

variable "common_name" {
  description = "Used as a more readable name, ie Monster Service instead of monster-service"
}

variable "docker_image" {
  description = "Used to specify the docker image repo and tag."
  default     = ""
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "512"
}

variable "fargate_memory" {
  description = "Defines how much RAM to provision in MB to the fargate instance."
  default     = "1024"
}

variable "instance_count" {
  description = "How many instance tasks to run."
  default     = 1
}

variable "max_instance_count" {
  description = "Defines maximum number of instance tasks to scale up to."
  default     = 4
}

variable "cluster_name" {
  description = "Name of the ECS Cluster"
  default     = "default-cluster"
}

variable "service_name" {
  description = "Name of the ECS Service"
  default     = "default-service"
}

variable "container_name" {
  description = "Name of the ECS Container"
  default     = "default-service-container"
}

variable "vpc_id" {
  description = "default VPC from DDB"
}

variable "public_subnets" {
  description = "public subnets for service from DDB"
  type        = list(string)
}

variable "private_subnets" {
  description = "private subnets for service from DDB"
  type        = list(string)
}

variable "ecs_role_policy_arns" {
  description = "ARNs used for the ECS Role"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
  ]
}

variable "environment_variables" {
  description = "Environment variables used locally in the task definition"
  default     = []
}

variable "group" {
  description = "Team Name"
}

variable "secrets" {
  description = "Secret parameters used locally in the task definition"
  default     = []
}

variable "cluster_id" {
  description = "ECS Cluster ID"
}

variable "deployment_minimum_healthy_percent" {
  description = "A lower limit on the number of tasks in a service that must remain in the RUNNING state during a deployment, as a percentage of the desired number of tasks (rounded up to the nearest integer)."
  default     = 100
}

variable "deployment_maximum_percent" {
  description = "An upper limit on the number of tasks in a service that are allowed in the RUNNING or PENDING state during a deployment, as a percentage of the desired number of tasks (rounded down to the nearest integer)"
  default     = 200
}

variable "entitlements_dynamo_table_prefix" {
  description = "Prefix of the tables to grant DynamoDB read access to."
  type        = string
}
