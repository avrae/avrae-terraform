variable "env" {
}

variable "service" {
}

# variable "account_id"                   {}
# variable "region"                       {}

variable "common_name" {
  description = "Used as a more readable name, ie Monster Service instead of monster-service"
}

variable "docker_image" {
  description = "Used to specify the docker image repo and tag."
  default     = ""
}

variable "service_port" {
  description = "Port serving traffic for the service."
  default     = 8081
}

variable "cluster_name" {
  description = "Name of the ECS Cluster"
  default     = "default-cluster"
}

variable "vpc_id" {
  description = "default VPC from DDB"
}

variable "public_subnets" {
  description = "public subnets for service from DDB"
  type        = list(string)
}

variable "private_subnets" {
  description = "public subnets for service from DDB"
  type        = list(string)
}

variable "public_ingress_cidr" {
  description = "CIDR range for allowed ingress to the application"
  default     = "0.0.0.0/0"
}

variable "hsv_ingress_cidr" {
  description = "CIDR range for allowed ingress to the application"
  default     = "69.85.223.168/29"
}

variable "alb_scheme" {
  description = "Switch ALB between internal or internet-facing"
  default     = "internet-facing"
}

variable "group" {
  description = "Team Name"
}

