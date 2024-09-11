# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION
# This is the common component configuration for jorge-cli-cluster. The common variables for each environment to
# deploy jorge-cli-cluster are defined here. This configuration will be merged into the environment configuration
# via an include block.
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  
  # Automatically load service-level variables
  service_vars = read_terragrunt_config(find_in_parent_folders("service.hcl"))

  # Extract out common variables for reuse
  env = local.environment_vars.locals.environment
  service_name = local.service_vars.locals.service_name

  # Expose the base source URL so different versions of the module can be deployed in different environments.
  base_source_url = "git::git@github.com:iagonc/cloud-infra-live.git//modules/aws/jorge-cli-asg"
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  cluster_name  = "${local.service_name}-${local.env}"
  instance_type = "t2.micro"
}