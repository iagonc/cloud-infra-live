# ------------------------------------------------------------------------------
# ASG
# ------------------------------------------------------------------------------

output "ami_info" {
  description = "Information about the AMI used for the cluster instances"
  value       = module.ami.ami_extra_info
}

# ------------------------------------------------------------------------------
# LOAD BALANCER
# ------------------------------------------------------------------------------

output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.load_balancer.dns_name
}