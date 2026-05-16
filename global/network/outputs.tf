output "transit_gateway_id" {
  value       = module.transit_gateway.transit_gateway_id
  description = "Transit Gateway ID."
}

output "shared_services_vpc_id" {
  value       = module.shared_services_vpc.vpc_id
  description = "Shared Services VPC ID."
}
