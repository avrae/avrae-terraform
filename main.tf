provider "aws" {
  region  = "${var.region}"
}

terraform {
  backend "atlas" {
      name = "fandom/avrae"
  }
}
