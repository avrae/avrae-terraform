provider "aws" {
  region  = "${var.region}"
}

terraform {
  backend "atlas" {
      name = "Fandom/avrae"
  }
}

# ECR - Taine
module "ecr_taine" {
  source  = "app.terraform.io/Fandom/ecr/aws"
  version = "1.0.0"

  env      = "${var.env}"
  service  = "${var.service}"
  group    = "${var.group}"
  ecr_name = "avrae/taine"
}

# ECR - Avrae Bot
module "ecr_avrae_bot" {
  source  = "app.terraform.io/Fandom/ecr/aws"
  version = "1.0.0"

  env      = "${var.env}"
  service  = "${var.service}"
  group    = "${var.group}"
  ecr_name = "avrae/avrae-bot"
}

# ECR - Avrae Service
module "ecr_avrae_service" {
  source  = "app.terraform.io/Fandom/ecr/aws"
  version = "1.0.0"

  env      = "${var.env}"
  service  = "${var.service}"
  group    = "${var.group}"
  ecr_name = "avrae/avrae-service"
}

# IAM Deploy User
module "iam_deploy" {
  source = "./modules/iam-deploy"
  
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
  source  = "./modules/ecs-fargate-bot"

  service               = "${var.service}"
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
                            {"name" = "DISCORD_TOKEN", "value" = ""},
                            {"name" = "GITHUB_TOKEN", "value" = ""}
                          ]
}
