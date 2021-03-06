provider "aws" {
  region = var.region
}

terraform {
  backend "atlas" {
    name = "Fandom/avrae"
  }
}

locals {
  common_tags = {
    Component   = var.service
    Environment = var.env
    Team        = var.group
  }
}

data "aws_acm_certificate" "certificate" {
  domain   = var.cert_domain
  statuses = ["ISSUED"]
}

# Secrets Manager Secret - New Relic License Key
resource "aws_secretsmanager_secret" "new_relic_license_key" {
  name        = "avrae/${var.env}/new-relic-license-key"
  description = "License key for New Relic."
  tags        = local.common_tags
}

# Secrets Manager Secret - Avrae Bot Sentry DSN
resource "aws_secretsmanager_secret" "avrae_bot_sentry_dsn" {
  name        = "avrae/${var.env}/avrae-bot-sentry-dsn"
  description = "Sentry DSN for Avrae Bot."
  tags        = local.common_tags
}

# Secrets Manager Secret - Avrae Service Sentry DSN
resource "aws_secretsmanager_secret" "avrae_service_sentry_dsn" {
  name        = "avrae/${var.env}/avrae-service-sentry-dsn"
  description = "Sentry DSN for Avrae Service."
  tags        = local.common_tags
}

# Secrets Manager Secret - Taine Discord Token
resource "aws_secretsmanager_secret" "taine_discord_token" {
  name        = "avrae/${var.env}/taine-discord-token"
  description = "Discord token for Taine."
  tags        = local.common_tags
}

# Secrets Manager Secret - Taine GitHub Token
resource "aws_secretsmanager_secret" "taine_github_token" {
  name        = "avrae/${var.env}/taine-github-token"
  description = "GitHub token for Taine."
  tags        = local.common_tags
}

# Secrets Manager Secret - Taine Sentry DSN
resource "aws_secretsmanager_secret" "taine_sentry_dsn" {
  name        = "avrae/${var.env}/taine-sentry-dsn"
  description = "Sentry DSN for Taine."
  tags        = local.common_tags
}

# Secrets Manager Secret - Mongo URL
resource "aws_secretsmanager_secret" "mongo_url" {
  name        = "avrae/${var.env}/mongo-url"
  description = "URL for MongoDB connection."
  tags        = local.common_tags
}

# Secrets Manager Secret - Avrae Discord Token
resource "aws_secretsmanager_secret" "avrae_bot_discord_token" {
  name        = "avrae/${var.env}/avrae-bot-discord-token"
  description = "Discord token for the Avrae Bot."
  tags        = local.common_tags
}

# Secrets Manager Secret - Avrae Discord Client Secret
resource "aws_secretsmanager_secret" "avrae_discord_client_secret" {
  name        = "avrae/${var.env}/avrae-discord-client-secret"
  description = "Discord client secret for the Avrae application."
  tags        = local.common_tags
}

# Secrets Manager Secret - Avrae Dicecloud Password
resource "aws_secretsmanager_secret" "avrae_bot_dicecloud_pass" {
  name        = "avrae/${var.env}/avrae-bot-dicecloud-pass"
  description = "Dicecloud password for the Avrae Bot."
  tags        = local.common_tags
}

# Secrets Manager Secret - Avrae Dicecloud Token
resource "aws_secretsmanager_secret" "avrae_bot_dicecloud_token" {
  name        = "avrae/${var.env}/avrae-bot-dicecloud-token"
  description = "Dicecloud token for the Avrae Bot."
  tags        = local.common_tags
}

# Secrets Manager Secret - Avrae Discord Bot List Token
resource "aws_secretsmanager_secret" "avrae_bot_dbl_token" {
  name        = "avrae/${var.env}/avrae-bot-dbl-token"
  description = "Discord Bot List token for the Avrae Bot."
  tags        = local.common_tags
}

# Secrets Manager Secret - Avrae Google API Service File
resource "aws_secretsmanager_secret" "avrae_bot_google_service" {
  name        = "avrae/${var.env}/avrae-bot-google-service"
  description = "Google Service Account for the Avrae Bot."
  tags        = local.common_tags
}

# Secrets Manager Secret - Avrae Nightly Discord Token
resource "aws_secretsmanager_secret" "avrae_bot_nightly_discord_token" {
  name        = "avrae/${var.env}/avrae-bot-nightly-discord-token"
  description = "Discord token for the Avrae Bot."
  tags        = local.common_tags
}

# Secrets Manager Secret - Avrae Service JWT Secret
resource "aws_secretsmanager_secret" "avrae_service_jwt_secret" {
  name        = "avrae/${var.env}/avrae-service-jwt-secret"
  description = "JWT secret for tokens issues to avrae.io from the avrae service."
  tags        = local.common_tags
}

# Secrets Manager Secret - Auth Service Secret
data "aws_secretsmanager_secret" "avrae_auth_service_secret" {
  name = "avrae/${var.env}/auth-service-secret"
}

# Secrets Manager Secret - Waterdeep JWT Key
data "aws_secretsmanager_secret" "waterdeep_jwt_secret" {
  name = "${var.env}/shared/waterdeep-jwt-key"
}

# Secrets Manager Secret - LaunchDarkly SDK Key (Prod)
data "aws_secretsmanager_secret" "avrae_bot_ld_sdk_key" {
  name        = "avrae/${var.env}/avrae-bot-ld-sdk-key"
}

# Secrets Manager Secret - LaunchDarkly SDK Key (Nightly)
data "aws_secretsmanager_secret" "avrae_bot_nightly_ld_sdk_key" {
  name        = "avrae/${var.env}/avrae-bot-nightly-ld-sdk-key"
}

# ECR - Taine
module "ecr_taine" {
  source  = "app.terraform.io/Fandom/ecr/aws"
  version = "1.12.2"

  env      = var.env
  service  = var.service
  group    = var.group
  ecr_name = "avrae/taine"
}

# ECR - Avrae Bot
module "ecr_avrae_bot" {
  source  = "app.terraform.io/Fandom/ecr/aws"
  version = "1.12.2"

  env      = var.env
  service  = var.service
  group    = var.group
  ecr_name = "avrae/avrae-bot"
}

# ECR - Avrae Service
module "ecr_avrae_service" {
  source  = "app.terraform.io/Fandom/ecr/aws"
  version = "1.12.2"

  env      = var.env
  service  = var.service
  group    = var.group
  ecr_name = "avrae/avrae-service"
}

# IAM Deploy User
module "iam_deploy" {
  source = "./modules/iam-deploy"

  env        = var.env
  service    = var.service
  region     = var.region
  account_id = var.account_id
  s3_prefix  = var.s3_prefix
}

# DynamoDB
module "dynamodb_taine" {
  source = "./modules/dynamodb-taine"

  service = var.service
  env     = var.env
  group   = var.group
}

# VPC
module "ecs_vpc" {
  source  = "app.terraform.io/Fandom/ddb_ecs_vpc/aws"
  version = "5.0.0"

  env           = var.env
  service       = var.service
  region        = var.region
  network_range = var.network_range
  common_name   = var.common_name
}

# ECS Fargate - Avrae Cluster
module "ecs_avrae" {
  source         = "app.terraform.io/Fandom/ecs_fargate_cluster/aws"
  version        = "2.12.0"
  #source = "./modules/terraform-aws-ecs_fargate_cluster"
  alb_scheme     = "internal"
  service        = var.service
  env            = var.env
  group          = var.group
  cluster_name   = "${var.service}-${var.env}"
  common_name    = var.common_name
  docker_image   = "${var.account_id}.dkr.ecr.us-east-1.amazonaws.com/avrae/taine:live"
  public_subnets = module.ecs_vpc.public_subnet_ids
  private_subnets = module.ecs_vpc.private_subnet_ids
  vpc_id         = module.ecs_vpc.aws_vpc_main_id
}

# ECS Fargate - Taine - Service
module "taine_ecs" {
  source             = "./modules/ecs-fargate"
  private_subnets    = module.ecs_vpc.private_subnet_ids
  public_subnets     = module.ecs_vpc.public_subnet_ids
  aws_lb_id          = module.ecs_avrae.lb_external_listener
  lb_sg_id           = module.ecs_avrae.lb_sg_id
  region             = var.region
  service            = "taine"
  service_name       = "taine"
  account_id         = var.account_id
  service_port       = 8378
  health_check       = "/github"
  instance_count     = 1
  max_instance_count = 1

  # restart container instantly on deploy
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
  lb_deregistration_delay            = 0

  vpc_id             = module.ecs_vpc.aws_vpc_main_id
  cluster_id         = module.ecs_avrae.cluster_id
  common_name        = "Taine"
  cluster_name       = "${var.service}-${var.env}"
  env                = var.env
  certificate_domain = var.cert_domain
  group              = var.group
  docker_image       = "${var.account_id}.dkr.ecr.us-east-1.amazonaws.com/avrae/taine:live"
  ecs_role_policy_arns = [
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    module.dynamodb_taine.dynamodb_iam_policy_arn,
  ]
  environment_variables = [
    {
      name = "DYNAMODB_URL"
      value  = "https://dynamodb.us-east-1.amazonaws.com"
    },
    {
      name = "NEW_RELIC_CONFIG_FILE"
      value  = "newrelic.ini"
    },
    {
      name = "NEW_RELIC_ENVIRONMENT"
      value  = "production"
    },
  ]
  secrets = [
    {
      name      = "DISCORD_TOKEN"
      valueFrom = aws_secretsmanager_secret.taine_discord_token.arn
    },
    {
      name      = "GITHUB_TOKEN"
      valueFrom = aws_secretsmanager_secret.taine_github_token.arn
    },
    {
      name      = "NEW_RELIC_LICENSE_KEY"
      valueFrom = aws_secretsmanager_secret.new_relic_license_key.arn
    },
    {
      name      = "SENTRY_DSN"
      valueFrom = aws_secretsmanager_secret.taine_sentry_dsn.arn
    },
  ]
}

# ECS Fargate - Avrae Service - Service
module "avrae_service_ecs" {
  source             = "./modules/ecs-fargate"
  private_subnets    = module.ecs_vpc.private_subnet_ids
  public_subnets     = module.ecs_vpc.public_subnet_ids
  aws_lb_id          = module.ecs_avrae.lb_external_listener
  lb_sg_id           = module.ecs_avrae.lb_sg_id
  region             = var.region
  service            = "avrae-service"
  service_name       = "avrae-service"
  account_id         = var.account_id
  service_port       = 8000
  instance_count     = 1
  vpc_id             = module.ecs_vpc.aws_vpc_main_id
  cluster_id         = module.ecs_avrae.cluster_id
  common_name        = "Avrae Service"
  cluster_name       = "${var.service}-${var.env}"
  env                = var.env
  certificate_domain = var.cert_domain
  group              = var.group
  docker_image       = "${var.account_id}.dkr.ecr.us-east-1.amazonaws.com/avrae/avrae-service:live"
  ecs_role_policy_arns = [
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
  ]
  environment_variables = [
    {
      name = "NEW_RELIC_CONFIG_FILE"
      value  = "newrelic.ini"
    },
    {
      name = "NEW_RELIC_ENVIRONMENT"
      value  = "production"
    },
    {
      name = "REDIS_URL"
      value  = "redis://${module.redis_avrae.hostname}"
    },
    {
      name = "DISCORD_CLIENT_ID"
      value  = var.discord_client_id
    },
    {
      name = "ELASTICSEARCH_ENDPOINT"
      value  = module.alias_workshop_elasticsearch.es_endpoint
    },
  ]
  secrets = [
    {
      name    = "MONGO_URL"
      valueFrom = aws_secretsmanager_secret.mongo_url.arn
    },
    {
      name      = "NEW_RELIC_LICENSE_KEY"
      valueFrom = aws_secretsmanager_secret.new_relic_license_key.arn
    },
    {
      name      = "SENTRY_DSN"
      valueFrom = aws_secretsmanager_secret.avrae_service_sentry_dsn.arn
    },
    {
      name      = "DISCORD_CLIENT_SECRET"
      valueFrom = aws_secretsmanager_secret.avrae_discord_client_secret.arn
    },
    {
      name      = "JWT_SECRET"
      valueFrom = aws_secretsmanager_secret.avrae_service_jwt_secret.arn
    },
    {
      name      = "DISCORD_BOT_TOKEN"
      valueFrom = aws_secretsmanager_secret.avrae_bot_discord_token.arn
    },
  ]
}

# ECS Fargate - Avrae Bot - Service
module "avrae_bot_ecs" {
  source          = "./modules/ecs-fargate-service-avrae"
  private_subnets = module.ecs_vpc.private_subnet_ids
  public_subnets  = module.ecs_vpc.public_subnet_ids
  region          = var.region
  service         = "avrae-bot"
  service_name    = "avrae-bot"
  account_id      = var.account_id
  vpc_id          = module.ecs_vpc.aws_vpc_main_id
  cluster_id      = module.ecs_avrae.cluster_id

  common_name  = "Avrae Bot"
  cluster_name = "${var.service}-${var.env}"
  env          = var.env
  group        = var.group
  docker_image = "${var.account_id}.dkr.ecr.us-east-1.amazonaws.com/avrae/avrae-bot:live"
  ecs_role_policy_arns = [
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
  ]
  environment_variables = [
    {
      name = "REDIS_URL"
      value  = "redis://${module.redis_avrae.hostname}"
    },
    {
      name = "DISCORD_OWNER_USER_ID"
      value  = var.discord_owner_id
    },
    {
      name = "DICECLOUD_USER"
      value  = var.dicecloud_username
    },
    {
      name = "NEW_RELIC_CONFIG_FILE"
      value  = "newrelic.ini"
    },
    {
      name = "NEW_RELIC_ENVIRONMENT"
      value  = "production"
    },
    {
      name = "NUM_CLUSTERS"
      value  = "8"
    },
    {
      name = "NUM_SHARDS"  # 3/9: set to 256 for scaleup on discord's end, todo remove to allow autoscaling
      value  = "256"
    },
    {
      name = "DDB_AUTH_SERVICE_URL"
      value  = var.auth_service_url
    },
    {
      name = "DYNAMO_USER_TABLE"
      value  = var.entitlements_user_dynamo_table
    },
    {
      name = "DYNAMO_ENTITY_TABLE"
      value  = var.entitlements_entity_dynamo_table
    },
    {
      name = "CHARACTER_COMPUTATION_ENDPOINT"
      value  = module.character_computation_api.api_endpoint
    },
    {
      name = "MONSTER_TOKEN_ENDPOINT"
      value = module.s3_avrae.token_s3_endpoint
    },
  ]
  secrets = [
    {
      name    = "MONGO_URL"
      valueFrom = aws_secretsmanager_secret.mongo_url.arn
    },
    {
      name      = "SENTRY_DSN"
      valueFrom = aws_secretsmanager_secret.avrae_bot_sentry_dsn.arn
    },
    {
      name      = "DISCORD_BOT_TOKEN"
      valueFrom = aws_secretsmanager_secret.avrae_bot_discord_token.arn
    },
    {
      name      = "DICECLOUD_PASS"
      valueFrom = aws_secretsmanager_secret.avrae_bot_dicecloud_pass.arn
    },
    {
      name      = "DICECLOUD_TOKEN"
      valueFrom = aws_secretsmanager_secret.avrae_bot_dicecloud_token.arn
    },
    {
      name      = "DBL_TOKEN"
      valueFrom = aws_secretsmanager_secret.avrae_bot_dbl_token.arn
    },
    {
      name      = "GOOGLE_SERVICE_ACCOUNT"
      valueFrom = aws_secretsmanager_secret.avrae_bot_google_service.arn
    },
    {
      name      = "NEW_RELIC_LICENSE_KEY"
      valueFrom = aws_secretsmanager_secret.new_relic_license_key.arn
    },
    {
      name      = "DDB_AUTH_SECRET"
      valueFrom = data.aws_secretsmanager_secret.avrae_auth_service_secret.arn
    },
    {
      name      = "DDB_AUTH_WATERDEEP_SECRET"
      valueFrom = data.aws_secretsmanager_secret.waterdeep_jwt_secret.arn
    },
    {
      name      = "LAUNCHDARKLY_SDK_KEY"
      valueFrom = data.aws_secretsmanager_secret.avrae_bot_ld_sdk_key.arn
    },
  ]

  # restart container instantly on deploy
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
  instance_count                     = 8  # MUST EQUAL NUM_CLUSTERS ENV VAR!
  max_instance_count                 = 8

  # 1 vCPU, 8GB RAM per cluster
  fargate_cpu    = 1024
  fargate_memory = 8192

  # entitlements Dynamo table names
  entitlements_dynamo_table_prefix = var.entitlements_dynamo_table_prefix
}

# ECS Fargate - Avrae Nightly - Service
module "avrae_bot_nightly_ecs" {
  source          = "./modules/ecs-fargate-service-avrae"
  private_subnets = module.ecs_vpc.private_subnet_ids
  public_subnets  = module.ecs_vpc.public_subnet_ids
  region          = var.region
  service         = "avrae-bot-nightly"
  service_name    = "avrae-bot-nightly"
  account_id      = var.account_id
  vpc_id          = module.ecs_vpc.aws_vpc_main_id
  cluster_id      = module.ecs_avrae.cluster_id

  common_name  = "Avrae Bot Nightly"
  cluster_name = var.service
  env          = var.env
  group        = var.group
  docker_image = "${var.account_id}.dkr.ecr.us-east-1.amazonaws.com/avrae/avrae-bot:nightly"
  ecs_role_policy_arns = [
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
  ]
  environment_variables = [
    {
      name = "REDIS_URL"
      value  = "redis://${module.redis_avrae.hostname}"
    },
    {
      name = "DISCORD_OWNER_USER_ID"
      value  = var.discord_owner_id
    },
    {
      name = "DICECLOUD_USER"
      value  = var.dicecloud_username
    },
    {
      name = "NEW_RELIC_CONFIG_FILE"
      value  = "newrelic.ini"
    },
    {
      name = "NEW_RELIC_ENVIRONMENT"
      value  = "staging"
    },
    {
      name = "MONGODB_DB_NAME"
      value  = "nightly"
    },
    {
      name = "REDIS_DB_NUM"
      value  = "1"
    },
    {
      name = "ENVIRONMENT"
      value  = "nightly"
    },
    {
      name = "DEFAULT_PREFIX"
      value  = "$"
    },
    {
      name = "NUM_CLUSTERS"
      value  = "1"
    },
    {
      name = "NUM_SHARDS"  # explicitly set num shards for clustering test
      value  = "2"
    },
    {
      name = "DDB_AUTH_SERVICE_URL"
      value  = var.auth_service_url
    },
    {
      name = "DYNAMO_USER_TABLE"
      value  = var.entitlements_user_dynamo_table
    },
    {
      name = "DYNAMO_ENTITY_TABLE"
      value  = var.entitlements_entity_dynamo_table
    },
    {
      name = "CHARACTER_COMPUTATION_ENDPOINT"
      value  = module.character_computation_api.api_endpoint
    },
    {
      name = "MONSTER_TOKEN_ENDPOINT"
      value = module.s3_avrae.token_s3_endpoint
    },
  ]
  secrets = [
    {
      name    = "MONGO_URL"
      valueFrom = aws_secretsmanager_secret.mongo_url.arn
    },
    {
      name      = "SENTRY_DSN"
      valueFrom = aws_secretsmanager_secret.avrae_bot_sentry_dsn.arn
    },
    {
      name      = "DISCORD_BOT_TOKEN"
      valueFrom = aws_secretsmanager_secret.avrae_bot_nightly_discord_token.arn
    },
    {
      name      = "DICECLOUD_PASS"
      valueFrom = aws_secretsmanager_secret.avrae_bot_dicecloud_pass.arn
    },
    {
      name      = "DICECLOUD_TOKEN"
      valueFrom = aws_secretsmanager_secret.avrae_bot_dicecloud_token.arn
    },
    {
      name      = "GOOGLE_SERVICE_ACCOUNT"
      valueFrom = aws_secretsmanager_secret.avrae_bot_google_service.arn
    },
    {
      name      = "NEW_RELIC_LICENSE_KEY"
      valueFrom = aws_secretsmanager_secret.new_relic_license_key.arn
    },
    {
      name      = "DDB_AUTH_SECRET"
      valueFrom = data.aws_secretsmanager_secret.avrae_auth_service_secret.arn
    },
    {
      name      = "DDB_AUTH_WATERDEEP_SECRET"
      valueFrom = data.aws_secretsmanager_secret.waterdeep_jwt_secret.arn
    },
    {
      name      = "LAUNCHDARKLY_SDK_KEY"
      valueFrom = data.aws_secretsmanager_secret.avrae_bot_nightly_ld_sdk_key.arn
    },
  ]

  # restart container instantly on deploy
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
  instance_count                     = 1  # MUST EQUAL NUM_CLUSTERS ENV VAR!
  max_instance_count                 = 1

  # 1 vCPU, 4GB RAM
  fargate_cpu    = 1024
  fargate_memory = 4096

  # entitlements Dynamo table names
  entitlements_dynamo_table_prefix = var.entitlements_dynamo_table_prefix
}

# listeners
resource "aws_lb_listener" "front_end_http" {
  load_balancer_arn = module.ecs_avrae.lb_external_listener
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = module.avrae_service_ecs.target_group_id
    type             = "forward"
  }
}

resource "aws_lb_listener" "front_end_https" {
  load_balancer_arn = module.ecs_avrae.lb_external_listener
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.certificate.arn

  default_action {
    target_group_arn = module.avrae_service_ecs.target_group_id
    type             = "forward"
  }
}

# taine.avrae.io/github
resource "aws_lb_listener_rule" "taine_ecs" {
  listener_arn = aws_lb_listener.front_end_http.arn

  action {
    type             = "forward"
    target_group_arn = module.taine_ecs.target_group_id
  }

  condition {
    path_pattern {
      values = ["/github*"]
    }
  }
}

resource "aws_lb_listener_rule" "taine_ecs_https" {
  listener_arn = aws_lb_listener.front_end_https.arn

  action {
    type             = "forward"
    target_group_arn = module.taine_ecs.target_group_id
  }

  condition {
    path_pattern {
      values = ["/github*"]
    }
  }
}

# Avrae DNS Zone
resource "aws_route53_zone" "service" {
  name = "${var.service}-${var.env}.curse.us"
  vpc {
    vpc_id = module.ecs_vpc.aws_vpc_main_id
  }
}

# game log lambda access
data "aws_security_group" "gamelog_avrae_lambda" {
  name = "game-log-lambda-${var.env}"
}

# Redis
module "redis_avrae" {
  source  = "app.terraform.io/Fandom/redis/aws"
  version = "4.12.0"
  #source = "./modules/terraform-aws-redis"
  name          = "Avrae"
  num_dbs       = "2"
  instance_type = "cache.t2.micro"
  common_name   = var.common_name
  env           = var.env
  service       = var.service
  group         = var.group
  redis_whitelist_sgs = [
    module.avrae_bot_ecs.security_group_id,
    module.avrae_bot_nightly_ecs.security_group_id,
    module.avrae_service_ecs.security_group_id,
    data.aws_security_group.gamelog_avrae_lambda.id,  # connect to redis from gamelog lambda
  ]
  num_redis_whitelist_sgs      = 4
  automatic_failover           = "true"
  engine_version               = "4.0.10"
  cluster_parameter_group_name = "default.redis4.0"
  parameter_group_name         = "default.redis4.0"
  #local_zone_id                = aws_route53_zone.service.id
  subnet_ids                   = module.ecs_vpc.private_subnet_ids
  vpc_id = module.ecs_vpc.aws_vpc_main_id
}

# MongoDB
module "mongodb_avrae" {
  source = "./modules/mongodb"
  mongodb_whitelist_sgs = list(
    aws_security_group.office_access.id, module.avrae_bot_ecs.security_group_id, module.avrae_service_ecs.security_group_id,
    module.avrae_bot_nightly_ecs.security_group_id, module.analytics_avrae.security_group_id, module.analytics_avrae.lambda_security_group_id
  )

  service          = var.service
  env              = var.env
  group            = var.group
  common_name      = var.common_name
  mongodb_username = var.mongodb_username
  mongodb_password = var.mongodb_password
  vpc_id           = module.ecs_vpc.aws_vpc_main_id
  subnet_ids       = module.ecs_vpc.private_subnet_ids
}

# SSH access to mongoDB
resource "aws_security_group" "office_access" {
  name        = "${var.service}-${var.env}-office-access"
  description = "Security group for access from the office"
  vpc_id      = module.ecs_vpc.aws_vpc_main_id
  tags = {
    Name = "${var.service}-${var.env} Office Access"
    env  = var.env
  }
}

resource "aws_security_group_rule" "huntsville" {
  count             = length(var.whitelist_cidrs) == 0 ? 0 : 1
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = var.whitelist_cidrs
  security_group_id = aws_security_group.office_access.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.office_access.id
}

resource "aws_key_pair" "dev_access" {
  key_name   = "avrae-dev-access"
  public_key = var.dev_access_pubkey
}

resource "aws_instance" "dev_mdb_access" {
  ami                         = "ami-0b898040803850657" # amazon linux 2
  instance_type               = "t2.micro"
  subnet_id                   = module.ecs_vpc.public_subnet_ids[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = list(aws_security_group.office_access.id)
  key_name                    = aws_key_pair.dev_access.key_name

  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.service}-dev-access"
    },
  )
}

# Analytics
module "analytics_avrae" {
  source = "./modules/avrae-analytics"

  service          = var.service
  env              = var.env
  group            = var.group
  common_name      = var.common_name
  region           = var.region
  s3_prefix        = var.s3_prefix
  vpc_id           = module.ecs_vpc.aws_vpc_main_id
  mongo_url_secret_arn = aws_secretsmanager_secret.mongo_url.arn
}

# ECR - Avrae.io
module "ecr_avrae_io" {
  source  = "app.terraform.io/Fandom/ecr/aws"
  version = "1.12.2"

  env      = var.env
  service  = var.service
  group    = var.group
  ecr_name = "avrae/avrae-io"
}

# ECS Fargate - Avrae io - Service
module "avrae_io_ecs" {
  source          = "./modules/ecs-fargate"
  private_subnets = module.ecs_vpc.private_subnet_ids
  public_subnets  = module.ecs_vpc.public_subnet_ids
  aws_lb_id       = module.ecs_avrae.lb_external_listener
  lb_sg_id        = module.ecs_avrae.lb_sg_id
  region          = var.region
  service         = "avrae-io"
  service_name    = "avrae-io"
  service_port    = 4000
  account_id      = var.account_id
  vpc_id          = module.ecs_vpc.aws_vpc_main_id
  cluster_id      = module.ecs_avrae.cluster_id

  common_name  = "Avrae io"
  cluster_name = "${var.service}-${var.env}"
  env          = var.env
  group        = var.group
  certificate_domain = var.cert_domain
  docker_image = "${var.account_id}.dkr.ecr.us-east-1.amazonaws.com/avrae/avrae-io:live"
  ecs_role_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
  ]

  # always have 1-3 containers running
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 150
  instance_count                     = 2
  max_instance_count                 = 2

  # 1 vCPU, 2GB RAM per container
  fargate_cpu    = 1024
  fargate_memory = 2048
}

resource "aws_lb_listener_rule" "avrae_io_https" {
  listener_arn = aws_lb_listener.front_end_https.arn

  action {
    type             = "forward"
    target_group_arn = module.avrae_io_ecs.target_group_id
  }

  condition {
    host_header {
      values = ["avrae.io","www.avrae.io"]
    }
  }
}

module "character_computation_api" {
  source        = "./modules/character-computation"
  env           = var.env
  service       = var.service
  subnet_ids    = module.ecs_vpc.private_subnet_ids
  vpc_id        = module.ecs_vpc.aws_vpc_main_id
  whitelist_sgs = [module.avrae_bot_ecs.security_group_id, module.avrae_bot_nightly_ecs.security_group_id]
}

module "alias_workshop_elasticsearch" {
  source = "./modules/es-alias-workshop"
  env               = var.env
  service           = var.service
  subnet_ids        = module.ecs_vpc.private_subnet_ids
  vpc_id            = module.ecs_vpc.aws_vpc_main_id
  es_whitelist_sgs  = [module.avrae_bot_ecs.security_group_id, module.avrae_bot_nightly_ecs.security_group_id, module.avrae_service_ecs.security_group_id]
}
    
module "s3_avrae" {
  source        = "./modules/s3-avrae"
  env           = var.env
  service       = var.service
  region        = var.region
  vpc_id        = module.ecs_vpc.aws_vpc_main_id
  s3_prefix     = var.s3_prefix
  subnet_ids    = module.ecs_vpc.private_subnet_ids
}
