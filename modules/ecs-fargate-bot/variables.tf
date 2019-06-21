variable "service" {
  description = "Service name of the account"
}

variable "env" {
  description = "Environment name"
}

variable "group" {
  description = "Group name of the account"
}

variable "region" {
  description = "AWS region"
}

variable "ecs_role_policy_arns" {
    description = "ARNs used for the ECS Role"
    type = "list"
}

variable "fargate_cpu" {
    description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
    default = "512" 
}

variable "fargate_memory" {
    description = "Defines how much RAM to provision in MB to the fargate instance."
    default = "1024" 
}

variable "docker_image" {
    description = "Used to specify the docker image repo and tag."
}

variable "environment_variables" {
    description = "Environment variables used locally in the task definition"
    type        = "list"
    default     = []
}

variable "instance_count" {
    description = "How many instance tasks to run."
    default = 1
}

variable "private_subnets" {
    description = "Private subnets for service"
    type = "list"
}

variable "vpc_id" {
    description = "Default VPC from DDB"
}
