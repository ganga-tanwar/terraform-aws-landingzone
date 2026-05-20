module "dns_resolver" {
  source = "../dns_resolver"

  name_prefix         = var.name_prefix
  vpc_id              = var.vpc_id
  subnet_ids          = var.subnet_ids
  on_premises_cidrs   = var.on_premises_cidrs
  dns_forward_domains = var.dns_forward_domains
  tags                = var.tags
}

module "vpn" {
  source = "../vpn"

  name_prefix                = var.name_prefix
  transit_gateway_id         = var.transit_gateway_id
  customer_gateway_ip        = var.customer_gateway_ip
  customer_gateway_bgp_asn   = var.customer_gateway_bgp_asn
  direct_connect_gateway_asn = var.direct_connect_gateway_asn
  tags                       = var.tags
}
