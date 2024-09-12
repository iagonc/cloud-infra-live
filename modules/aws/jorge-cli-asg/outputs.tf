# ------------------------------------------------------------------------------
# LOAD BALANCER
# ------------------------------------------------------------------------------

output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.load_balancer.dns_name
}
