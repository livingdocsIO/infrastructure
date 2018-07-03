variable "aws_production_access_key" {}
variable "aws_production_secret_key" {}
variable "aws_production_region" {}

provider "aws" {
  version = ">= 1.15"
  access_key = "${var.aws_production_access_key}"
  secret_key = "${var.aws_production_secret_key}"
  region = "${var.aws_production_region}"
}
