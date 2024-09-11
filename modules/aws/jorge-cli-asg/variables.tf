# ------------------------------------------------------------------------------
# ENVIRONMENT
# ------------------------------------------------------------------------------

variable "environment" {
  description = "The environment name"
  type        = string
  default     = null
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
  default     = null
}

variable "account_id" {
  description = "The account ID"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# BASIC INFO
# ------------------------------------------------------------------------------

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

# ------------------------------------------------------------------------------
# ASG/EC2 INSTANCES
# ------------------------------------------------------------------------------

variable "asg_min_size" {
  description = "The min size of the cluster Auto Scaling Group"
  type        = number
}

variable "asg_max_size" {
  description = "The max size of the cluster Auto Scaling Group"
  type        = number
}

variable "asg_desired_size" {
  description = "The desired size of the cluster Auto Scaling Group"
  type        = number
}

variable "instance_type" {
  description = "The type of the cluster instance"
  type        = string
}

variable "key_pair_name" {
  description = "The name of a key pair to use for the cluster instances. Only recommended for debugging purposes, do **not** use in production!"
  type        = string
  default     = null
}

variable "ami_name" {
  description = "The name of the AMI to use for the cluster instances"
  type        = string
  default     = null
}

variable "protect_from_scale_in" {
  description = "Whether to enable scale-in protection. The ASG will not select instances with this setting for termination during scale-in events"
  type        = bool
  default     = false
}

variable "disable_api_termination" {
  description = "Whether to disable the termination of instances via Console and/or API. **WARNING:** does NOT protect against ASG changes - see `protect_from_scale_in`"
  type        = bool
  default     = false
}
