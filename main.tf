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


data "aws_acm_certificate" "certificate" {
  domain   = "*.dndbeyond.com"
  statuses = ["ISSUED"]
}

# Secrets Manager Secret - Avrae Bot Sentry DSN
resource "aws_secretsmanager_secret" "avrae_bot_sentry_dsn" {
  name        = "avrae/${var.env}/avrae-bot-sentry-dsn"
  description = "Sentry DSN for Avrae Bot."
  tags        = "${local.common_tags}"
}

# Secrets Manager Secret - Avrae Service Sentry DSN
resource "aws_secretsmanager_secret" "avrae_service_sentry_dsn" {
  name        = "avrae/${var.env}/avrae-service-sentry-dsn"
  description = "Sentry DSN for Avrae Service."
  tags        = "${local.common_tags}"
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

# Secrets Manager Secret - Taine Sentry DSN
resource "aws_secretsmanager_secret" "taine_sentry_dsn" {
  name        = "avrae/${var.env}/taine-sentry-dsn"
  description = "Sentry DSN for Taine."
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

# DynamoDB
module "dynamodb_taine" {
  source      = "./modules/dynamodb-taine"
  
  service     = "${var.service}"
  env         = "${var.env}"
  group       = "${var.group}"
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

# ECS Fargate - Avrae Cluster
module "ecs_avrae" {
  source  = "app.terraform.io/Fandom/ecs_fargate_cluster/aws"
  version = "1.0.0"
  alb_scheme            = "internal"
  service               = "${var.service}"
  env                   = "${var.env}"
  group                 = "${var.group}"
  cluster_name          = "${var.service}-${var.env}"
  common_name           = "${var.common_name}"
  docker_image          = "${var.account_id}.dkr.ecr.us-east-1.amazonaws.com/avrae/taine:live"
  public_subnets       = ["${module.ecs_vpc.public_subnet_ids}"]
  vpc_id                = "${module.ecs_vpc.aws_vpc_main_id}"
}

# ECS Fargate - Taine - Service
module "taine_ecs" {
  source  = "app.terraform.io/Fandom/ecs_fargate_service/aws"
  version = "1.2.0"
  private_subnets       = ["${module.ecs_vpc.private_subnet_ids}"]
  public_subnets        = ["${module.ecs_vpc.public_subnet_ids}"]
  aws_lb_id             = "${module.ecs_avrae.lb_external_listener}"
  lb_sg_id              = "${module.ecs_avrae.lb_sg_id}"
  region                = "${var.region}"
  service               = "taine"
  service_name          = "taine"
  account_id            = "${var.account_id}"
  service_port          = 8378
  health_check          = "/github"
  instance_count        = 1

  # restart container instantly on deploy
  deployment_minimum_healthy_percent  = 0
  deployment_maximum_percent          = 100
  lb_deregistration_delay             = 0

  vpc_id                = "${module.ecs_vpc.aws_vpc_main_id}"
  cluster_id            = "${module.ecs_avrae.cluster_id}"
  common_name           = "Taine"
  cluster_name          = "${var.service}-${var.env}"
  env                   = "${var.env}"
  certificate_domain    = "*.dndbeyond.com"
  group                 = "${var.group}"
  docker_image          = "${var.account_id}.dkr.ecr.us-east-1.amazonaws.com/avrae/taine:live"
  ecs_role_policy_arns  = [
                            "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
                            "arn:aws:iam::aws:policy/CloudWatchFullAccess",
                            "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
                            "${module.dynamodb_taine.dynamodb_iam_policy_arn}"
                          ]
  environment_variables = [
                            {"name" = "DYNAMODB_URL", value = "https://dynamodb.us-east-1.amazonaws.com"}
                          ]
  secrets               = [
                            {"name" = "DISCORD_TOKEN", "valueFrom" = "${aws_secretsmanager_secret.taine_discord_token.arn}"},
                            {"name" = "GITHUB_TOKEN", "valueFrom" = "${aws_secretsmanager_secret.taine_github_token.arn}"},
                            {"name" = "SENTRY_DSN", "valueFrom" = "${aws_secretsmanager_secret.taine_sentry_dsn.arn}"}
                          ]
}

# ECS Fargate - Avrae Service - Service
module "avrae_service_ecs" {
  source  = "app.terraform.io/Fandom/ecs_fargate_service/aws"
  version = "1.0.1"
  private_subnets       = ["${module.ecs_vpc.private_subnet_ids}"]
  public_subnets        = ["${module.ecs_vpc.public_subnet_ids}"]
  aws_lb_id             = "${module.ecs_avrae.lb_external_listener}"
  lb_sg_id              = "${module.ecs_avrae.lb_sg_id}"
  region                = "${var.region}"
  service               = "avrae-service"
  service_name          = "avrae-service"
  account_id            = "${var.account_id}"
  service_port          = 80
  vpc_id                = "${module.ecs_vpc.aws_vpc_main_id}"
  cluster_id            = "${module.ecs_avrae.cluster_id}"
  common_name           = "Avrae Service"
  cluster_name          = "${var.service}-${var.env}"
  env                   = "${var.env}"
  certificate_domain    = "*.dndbeyond.com"
  group                 = "${var.group}"
  docker_image          = "${var.account_id}.dkr.ecr.us-east-1.amazonaws.com/avrae/avrae-service:live"
  ecs_role_policy_arns  = [
                            "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
                          ]
  environment_variables = [
                            {"name" = "AVRAE_MONGO_URL", value = "${module.mongodb_avrae.hostname}"},
                            {"name" = "AVRAE_REDIS_URL", value = "${module.redis_avrae.hostname}"}
                          ]
  secrets               = [
                            {"name" = "SENTRY_DSN", "valueFrom" = "${aws_secretsmanager_secret.avrae_service_sentry_dsn.arn}"}
                          ]
}

# ECS Fargate - Avrae Bot - Service
module "avrae_bot_ecs" {
  source  = "app.terraform.io/Fandom/ecs_fargate_service/aws"
  version = "1.0.1"
  private_subnets       = ["${module.ecs_vpc.private_subnet_ids}"]
  public_subnets        = ["${module.ecs_vpc.public_subnet_ids}"]
  aws_lb_id             = "${module.ecs_avrae.lb_internal_listener}"
  lb_sg_id              = "${module.ecs_avrae.lb_sg_id}"
  region                = "${var.region}"
  service               = "avrae-bot"
  service_name          = "avrae-bot"
  account_id            = "${var.account_id}"
  service_port          = 80
  instance_count        = 1
  vpc_id                = "${module.ecs_vpc.aws_vpc_main_id}"
  cluster_id            = "${module.ecs_avrae.cluster_id}"
  common_name           = "Avrae Bot"
  cluster_name          = "${var.service}-${var.env}"
  env                   = "${var.env}"
  certificate_domain    = "*.dndbeyond.com"
  group                 = "${var.group}"
  docker_image          = "${var.account_id}.dkr.ecr.us-east-1.amazonaws.com/avrae/avrae-service:live"
  ecs_role_policy_arns  = [
                            "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
                          ]
  environment_variables = [
                            {"name" = "MONGO_URL", value = "${module.mongodb_avrae.hostname}"},
                            {"name" = "REDIS_URL", value = "${module.redis_avrae.hostname}"}
                          ]
  secrets               = [
                            {"name" = "SENTRY_DSN", "valueFrom" = "${aws_secretsmanager_secret.avrae_bot_sentry_dsn.arn}"}
                          ]
}


resource "aws_lb_listener" "front_end_http" {
  load_balancer_arn = "${module.ecs_avrae.lb_external_listener}" 
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${module.avrae_service_ecs.target_group_id}" 
    type             = "forward"
  }
}

resource "aws_lb_listener" "front_end_https" {
  load_balancer_arn = "${module.ecs_avrae.lb_external_listener}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${data.aws_acm_certificate.certificate.arn}"

  default_action {
    target_group_arn = "${module.avrae_service_ecs.target_group_id}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "internal" {
  load_balancer_arn = "${module.ecs_avrae.lb_internal_listener}" 
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${module.avrae_bot_ecs.target_group_id}" 
    type             = "forward"
  }
}
resource "aws_lb_listener_rule" "taine_ecs" {
  listener_arn = "${aws_lb_listener.front_end_http.arn}"

  action {
    type             = "forward"
    target_group_arn = "${module.taine_ecs.target_group_id}"
  }

  condition {
    field  = "path-pattern"
    values = ["/github*"]
  }
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

# MongoDB
module "mongodb_avrae" {
  source = "./modules/mongodb"
  mongodb_whitelist_sgs = "${aws_instance.dev_mdb_access.vpc_security_group_ids}" # ["${aws_security_group.office_access.id}"]
  service               = "${var.service}"
  env                   = "${var.env}"
  group                 = "${var.group}"
  common_name           = "${var.common_name}"
  mongodb_username      = "${var.mongodb_username}"
  mongodb_password      = "${var.mongodb_password}"
  vpc_id                = "${module.ecs_vpc.aws_vpc_main_id}"
  subnet_ids            = [
                            "${module.ecs_vpc.private_subnet_ids}"
                          ]
}

# SSH access to mongoDB
resource "aws_security_group" "office_access" {
  name        = "office-access${var.env}-${var.service}"
  description = "Security group for access from the office"
  vpc_id               = "${module.ecs_vpc.aws_vpc_main_id}"
  tags {
    Name = "${var.env}-${var.service} Office Access"
    env = "${var.env}"
  }
}

resource "aws_security_group_rule" "huntsville" {
  count             = "${length(var.whitelist_cidrs) == 0 ? 0 : 1}"
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["${var.whitelist_cidrs}"]
  security_group_id = "${aws_security_group.office_access.id}"
}

resource "aws_key_pair" "dev_access" {
  key_name   = "avrae-dev-access"
  public_key = "${var.dev_access_pubkey}"
}

resource "aws_instance" "dev_mdb_access" {
  ami                         = "ami-0b898040803850657"  # amazon linux 2
  instance_type               = "t2.micro"
  subnet_id                   = "${module.ecs_vpc.public_subnet_ids[0]}"
  associate_public_ip_address = true
  vpc_security_group_ids      = [ "${aws_security_group.office_access.id}" ]
  key_name                    = "${aws_key_pair.dev_access.key_name}"

  tags = "${merge(local.common_tags,
            map(
                "Name", "${var.service}-dev-access"
            )
          )}"
}
