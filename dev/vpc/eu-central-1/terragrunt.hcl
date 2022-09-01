locals {
  vars_environment = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  vars_service = read_terragrunt_config("service.hcl")
  vars_region = read_terragrunt_config("region.hcl")
  env = local.vars_environment.locals.environment
  region = local.vars_region.locals.region
  service_name = local.vars_service.locals.service_name
}
include "root" {
  path = find_in_parent_folders()
}
terraform {
  source = "git::ssh://git@github.com:mikhailznak/trf-iac.git"
}

inputs = {
  vpc_cidr_block = "10.0.0.0/16"
  tags = {
    Managed = "Terraform"
    Env     = local.env
  }
  vpc_name = "${local.env}-default-${local.service_name}"
  subnet_availability_zone = ["eu-central-1a"]
  subnet_private_cidrs     = ["10.0.0.0/20"]
  subnet_public_cidrs      = ["10.0.32.0/20"]
  subnet_database_cidrs    = ["10.0.64.0/20"]
  default_route_table_routes = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = "self"
    }
  ]
}