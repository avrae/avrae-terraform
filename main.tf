provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "atlas" {
      name = "Fandom/avrae"
  }
}

locals {
  common_tags = {
    Component   = "${var.service}"
    Environment = "${var.env}"
    Team        = "${var.group}"
  }
}

# Secrets Manager Secret - Taine Discord Token
resource "aws_secretsmanager_secret" "taine_discord_token" {
  name        = "avrae/${var.env}/taine-discord-token"
  description = "Discord token for Taine."
  tags        = "${local.common_tags}"
}

# Secrets Manager Secret - Taine GitHub Token
resource "aws_secretsmanager_secret" "taine_github_token" {
  name        = "avrae/${var.env}/taine-github-token"
  description = "GitHub token for Taine."
  tags        = "${local.common_tags}"
}

# ECR - Taine
module "ecr_taine" {
  source   = "app.terraform.io/Fandom/ecr/aws"
  version  = "1.0.0"

  env      = "${var.env}"
  service  = "${var.service}"
  group    = "${var.group}"
  ecr_name = "avrae/taine"
}

# ECR - Avrae Bot
module "ecr_avrae_bot" {
  source   = "app.terraform.io/Fandom/ecr/aws"
  version  = "1.0.0"

  env      = "${var.env}"
  service  = "${var.service}"
  group    = "${var.group}"
  ecr_name = "avrae/avrae-bot"
}

# ECR - Avrae Service
module "ecr_avrae_service" {
  source   = "app.terraform.io/Fandom/ecr/aws"
  version  = "1.0.0"

  env      = "${var.env}"
  service  = "${var.service}"
  group    = "${var.group}"
  ecr_name = "avrae/avrae-service"
}

# IAM Deploy User
module "iam_deploy" {
  source      = "./modules/iam-deploy"
  
  env         = "${var.env}"
  service     = "${var.service}"
  region      = "${var.region}"
  account_id  = "${var.account_id}"
}

# VPC
module "ecs_vpc" {
  source          = "app.terraform.io/Fandom/ddb_ecs_vpc/aws"
  version         = "2.0.0"

  env             = "${var.env}"
  service         = "${var.service}"
  region          = "${var.region}"
  vpc_env         = "production"
  network_range   = "10.124.15.0/24"
  common_name     = "Avrae"
}

# ECS - Taine
module "ecs_taine" {
  source                = "./modules/ecs-fargate-bot"

  service               = "taine"
  env                   = "${var.env}"
  group                 = "${var.group}"
  region                = "${var.region}"
  ecs_role_policy_arns  = [
                            "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
                            "arn:aws:iam::aws:policy/CloudWatchFullAccess",
                            "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
                          ]
  docker_image          = "${var.account_id}.dkr.ecr.us-east-1.amazonaws.com/avrae/taine:live"
  private_subnets       = ["${module.ecs_vpc.private_subnet_ids}"]
  vpc_id                = "${module.ecs_vpc.aws_vpc_main_id}"
  environment_variables = [
                            {"name" = "DYNAMODB_URL", value = "https://dynamodb.us-east-1.amazonaws.com"}
                          ]
  secrets               = [
                            {"name" = "DISCORD_TOKEN", "valueFrom" = "${aws_secretsmanager_secret.taine_discord_token.arn}"},
                            {"name" = "GITHUB_TOKEN", "valueFrom" = "${aws_secretsmanager_secret.taine_github_token.arn}"}
                          ]
}

# Avrae DNS Zone
resource "aws_route53_zone" "service" {
  name = "${var.service}-${var.env}.curse.us"
  vpc {
    vpc_id = "${module.ecs_vpc.aws_vpc_main_id}"
  }
}

# Redis
module "redis_avrae" {
  source                       = "app.terraform.io/Fandom/redis/aws"
  version                      = "2.0.2"

  name                         = "Avrae"
  num_dbs                      = "2"
  instance_type                = "cache.m5.large"
  common_name                  = "${var.common_name}"
  env                          = "${var.env}"
  service                      = "${var.service}"
  group                        = "${var.group}"
  redis_whitelist_sgs          = []
  automatic_failover           = "true"
  engine_version               = "4.0.10"
  cluster_parameter_group_name = "default.redis4.0"
  parameter_group_name         = "default.redis4.0"
  local_zone_id                = "${aws_route53_zone.service.id}"
  subnet_ids                   = [
                                  "${module.ecs_vpc.private_subnet_ids}"
                                ]
  vpc_id                       = "${module.ecs_vpc.aws_vpc_main_id}"
}
