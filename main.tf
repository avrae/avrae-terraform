provider "aws" {
  region  = "${var.region}"
}

terraform {
  backend "atlas" {
      name = "fandom/avrae"
  }
}

module "ecr" {
  source  = "app.terraform.io/Fandom/ecr/aws"
  version = "1.0.0"

  env      = "${var.env}"
  service  = "${var.service}"
  group    = "${var.group}"
  ecr_name = "avrae/taine"
}
