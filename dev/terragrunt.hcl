locals {
  vars_region = read_terragrunt_config("region.hcl")
  vars_environment = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  vars_service = read_terragrunt_config("service.hcl")
  vars_provider = read_terragrunt_config(find_in_parent_folders("provider.hcl"))
  region      = local.vars_region.locals.region
  access_key  = local.vars_provider.locals.access_key
  secret_key  = local.vars_provider.locals.secret_key
}

remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "state-storage"
    key            = "${local.vars_environment.locals.environment}/${local.vars_service.locals.service_name}/${local.vars_region.locals.region}/terraform.tfstate"
    region         = "eu-central-1"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
}


generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region     = "${local.region}"
  access_key = "${local.access_key}"
  secret_key = "${local.secret_key}"
}
EOF
}

inputs = merge(
  local.vars_environment.locals,
  local.vars_service.locals,
  local.vars_provider.locals,
  local.vars_region.locals,
)