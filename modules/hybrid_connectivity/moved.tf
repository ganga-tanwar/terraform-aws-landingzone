moved {
  from = aws_security_group.resolver
  to   = module.dns_resolver.aws_security_group.resolver
}

moved {
  from = aws_route53_resolver_endpoint.inbound
  to   = module.dns_resolver.aws_route53_resolver_endpoint.inbound
}

moved {
  from = aws_route53_resolver_endpoint.outbound
  to   = module.dns_resolver.aws_route53_resolver_endpoint.outbound
}

moved {
  from = aws_customer_gateway.this[0]
  to   = module.vpn.aws_customer_gateway.this[0]
}

moved {
  from = aws_vpn_connection.this[0]
  to   = module.vpn.aws_vpn_connection.this[0]
}

moved {
  from = aws_dx_gateway.this
  to   = module.vpn.aws_dx_gateway.this[0]
}
