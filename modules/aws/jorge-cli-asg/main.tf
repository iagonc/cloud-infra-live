# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  vpc_id          = data.aws_vpc.default.id
  vpc_cidr_blocks = data.aws_vpc.default.cidr_block_associations[*].cidr_block
  cidr_blocks     = var.custom_cidr != null ? concat(local.vpc_cidr_blocks, [var.custom_cidr]) : local.vpc_cidr_blocks
  server_port     = 80
}

# ------------------------------------------------------------------------------
# LB - SECURITY GROUP
# ------------------------------------------------------------------------------

module "lb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.2.0"

  name        = format("%s-lb", var.cluster_name)
  description = format("%s - LB", var.cluster_name)
  vpc_id      = local.vpc_id

  ingress_cidr_blocks = local.cidr_blocks

  ingress_with_cidr_blocks = [
    {
      from_port   = local.server_port
      to_port     = local.server_port
      protocol    = "HTTP"
      description = "HTTP"
      cidr_blocks = join(",", local.cidr_blocks)
    },
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = join(",", local.cidr_blocks)
    },
  ]
}

# ------------------------------------------------------------------------------
# LOAD BALANCER
# ------------------------------------------------------------------------------

module "load_balancer" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.11.0"

  name = var.cluster_name

  enable_deletion_protection = false

  vpc_id  = local.vpc_id
  subnets = data.aws_subnets.default.ids

  create_security_group = false
  security_groups       = [module.lb_security_group.security_group_id]

  listeners = {
    http = {
      port     = local.server_port
      protocol = "HTTP"
      forward = {
        target_group_key = "http"
      }
    }
  }

  # NOTE: target group attachments are explicitly disabled in this input because they
  # must be managed by the 'aws_autoscaling_traffic_source_attachment' resource later
  target_groups = {
    http = {
      name              = "${var.cluster_name}-http"
      protocol          = "HTTP"
      port              = local.server_port
      target_type       = "instance"
      create_attachment = false
    }
  }
}

# ------------------------------------------------------------------------------
# ASG - SECURITY GROUP
# ------------------------------------------------------------------------------

module "asg_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.2.0"

  name        = format("%s-ec2", var.cluster_name)
  description = format("%s - EC2 instances", var.cluster_name)
  vpc_id      = local.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      description              = "Load balancer"
      source_security_group_id = module.lb_security_group.security_group_id
    },
  ]

  ingress_with_self = [
    {
      # Ensure cluster instances have full access to each other
      rule        = "all-all"
      description = "Self"
    },
  ]

  egress_rules = ["all-all"]
}

resource "aws_security_group_rule" "server_tcp_rules" {
  security_group_id = module.asg_security_group.security_group_id

  type        = "ingress"
  cidr_blocks = local.cidr_blocks
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  description = "SSH"
}

# ------------------------------------------------------------------------------
# AUTO SCALING GROUP
# ------------------------------------------------------------------------------

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "8.0.0"

  # Auto scaling group
  name            = var.cluster_name
  use_name_prefix = false

  min_size              = var.asg_min_size
  max_size              = var.asg_max_size
  desired_capacity      = var.asg_desired_size
  protect_from_scale_in = var.protect_from_scale_in

  vpc_zone_identifier = data.aws_subnets.default.ids

  termination_policies = [
    "OldestInstance",
  ]

  # Launch template
  launch_template_use_name_prefix = false

  update_default_version  = true
  disable_api_termination = var.disable_api_termination

  instance_type = var.instance_type
  image_id      = data.aws_ami.ubuntu.id
  key_name      = var.key_pair_name
  user_data = base64encode(templatefile("${path.module}/user-data/user-data.sh", {
    repo_url = var.repo_url,
  }))

  security_groups = [module.asg_security_group.security_group_id]

  scaling_policies = {
    avg-cpu-policy-greater-than-10 = {
      policy_type = "TargetTrackingScaling"
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 10.0
      }
    }
  }
}

# ------------------------------------------------------------------------------
# ASG - TRAFFIC SOURCE ATTACHMENT
# ------------------------------------------------------------------------------

resource "aws_autoscaling_traffic_source_attachment" "this" {
  for_each = module.load_balancer.target_groups

  autoscaling_group_name = module.asg.autoscaling_group_name

  traffic_source {
    identifier = each.value.arn
    type       = "elbv2"
  }
}
