include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/_envcommon/jorge-cli-cluster.hcl"
  expose = true
}

terraform {
  source = "${include.envcommon.locals.base_source_url}"
}

# ---------------------------------------------------------------------------------------------------------------------
# INPUTS
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  instance_type = "t2.micro"
  custom_cidr   = "0.0.0.0/0"
  ansible_repo  = "iagonc/ansible-ops"

  asg_min_size     = 1
  asg_max_size     = 3
  asg_desired_size = 2

  key_pair_name = "my_keypair"
}
