provider "aws" {
  region  = "${var.region}"
}

terraform {
  required_version = "0.11.11"
  backend "atlas" {
      name = "fandom/avrae"
  }
}
