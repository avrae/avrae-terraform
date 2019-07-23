variable "env" {}
variable "service" {}
variable "account_id" {}
variable "region" {}

variable "common_name" {
  description = "Used as a more readable name, ie Monster Service instead of monster-service"
}

variable "docker_image" {
  description = "Used to specify the docker image repo and tag."
  default = ""
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default = "512"
}

variable "fargate_memory" {
  description = "Defines how much RAM to provision in MB to the fargate instance."
  default = "1024"
}

variable "service_port" {
  description = "Port serving traffic for the service."
  default = 8081
}

variable "instance_count" {
  description = "How many instance tasks to run."
  default = 1
}

variable "max_instance_count" {
  description = "Defines maximum number of instance tasks to scale up to."
  default = 4
}

variable "cluster_name" {
  description = "Name of the ECS Cluster"
  default = "default-cluster"
}

variable "service_name" {
  description = "Name of the ECS Service"
  default = "default-service"
}

variable "container_name" {
  description = "Name of the ECS Container"
  default = "default-service-container"
}

variable "health_check" {
  description = "Used to verify that the endpoint is healthy"
  default = "/"
}

variable "vpc_id" {
  description = "default VPC from DDB"
}

variable "public_subnets" {
  description = "public subnets for service from DDB"
  type = "list"
}

variable "private_subnets" {
  description = "private subnets for service from DDB"
  type = "list"
}

variable "ecs_role_policy_arns" {
  description = "ARNs used for the ECS Role"
  type = "list"
  default = [
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}

variable "certificate_domain" {
  description = "Used to name the certificate you'd like to use with the service, ie *.dndbeyond.com"
}

variable "environment_variables" {
  description = "Environment variables used locally in the task definition"
  default = []
}


variable "alb_scheme" {
  description = "Switch ALB between internal or internet-facing"
  default = "internet-facing"
}

variable "scale_target_value" {
  description = "Target load for scaling, currently using metric ECSServiceAverageCPUUtilization"
  default = 25
}

variable "scale_in_cooldown" {
  description = "The amount of time, in seconds, after a scale in activity completes before another scale in activity can start."
  default = 60
}

variable "scale_out_cooldown" {
  description = "The amount of time, in seconds, after a scale out activity completes before another scale out activity can start."
  default = 180
}

variable "scale_metric" {
  description = "Metric to use for autoscaling, default is CPU"
  default = "ECSServiceAverageCPUUtilization"
}

variable "group" {
  description = "Team Name"
}

variable "secrets" {
  description = "Secret parameters used locally in the task definition"
  default = []
}

variable "cluster_id" {
  description = "ECS Cluster ID"
}

variable "aws_lb_id" {

}

variable "lb_sg_id" {

}

variable "lb_deregistration_delay" {
  description = "The time to wait for in-flight requests to complete while deregistering a target. During this time, the state of the target is draining. [0..3600]"
  default = 300
}

variable "deployment_minimum_healthy_percent" {
  description = "A lower limit on the number of tasks in a service that must remain in the RUNNING state during a deployment, as a percentage of the desired number of tasks (rounded up to the nearest integer)."
  default = 100
}

variable "deployment_maximum_percent" {
  description = "An upper limit on the number of tasks in a service that are allowed in the RUNNING or PENDING state during a deployment, as a percentage of the desired number of tasks (rounded down to the nearest integer)"
  default = 200
}
