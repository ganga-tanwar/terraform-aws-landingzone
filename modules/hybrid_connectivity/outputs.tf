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

output "direct_connect_gateway_id" {
  value       = module.vpn.direct_connect_gateway_id
  description = "Direct Connect Gateway ID."
}
