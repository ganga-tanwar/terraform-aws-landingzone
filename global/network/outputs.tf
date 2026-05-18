output "transit_gateway_id" {
  value       = module.transit_gateway.transit_gateway_id
  description = "Transit Gateway ID."
}

output "shared_services_vpc_id" {
  value       = module.shared_services_vpc.vpc_id
  description = "Shared Services VPC ID."
}

output "inbound_resolver_endpoint_id" {
  value       = module.dns_resolver.inbound_resolver_endpoint_id
  description = "Inbound resolver endpoint ID."
}

output "outbound_resolver_endpoint_id" {
  value       = module.dns_resolver.outbound_resolver_endpoint_id
  description = "Outbound resolver endpoint ID."
}

output "vpn_connection_id" {
  value       = module.vpn.vpn_connection_id
  description = "VPN connection ID when created."
}
