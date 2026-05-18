moved {
  from = module.shared_services_vpc.aws_vpc_endpoint.gateway["s3"]
  to   = module.shared_services_endpoints.aws_vpc_endpoint.gateway["s3"]
}

moved {
  from = module.shared_services_vpc.aws_vpc_endpoint.gateway["dynamodb"]
  to   = module.shared_services_endpoints.aws_vpc_endpoint.gateway["dynamodb"]
}

moved {
  from = module.shared_services_vpc.aws_vpc_endpoint.interface["ssm"]
  to   = module.shared_services_endpoints.aws_vpc_endpoint.interface["ssm"]
}

moved {
  from = module.shared_services_vpc.aws_vpc_endpoint.interface["ssmmessages"]
  to   = module.shared_services_endpoints.aws_vpc_endpoint.interface["ssmmessages"]
}

moved {
  from = module.shared_services_vpc.aws_vpc_endpoint.interface["ec2messages"]
  to   = module.shared_services_endpoints.aws_vpc_endpoint.interface["ec2messages"]
}

moved {
  from = module.shared_services_vpc.aws_vpc_endpoint.interface["logs"]
  to   = module.shared_services_endpoints.aws_vpc_endpoint.interface["logs"]
}

moved {
  from = module.shared_services_vpc.aws_vpc_endpoint.interface["monitoring"]
  to   = module.shared_services_endpoints.aws_vpc_endpoint.interface["monitoring"]
}

moved {
  from = module.shared_services_vpc.aws_vpc_endpoint.interface["kms"]
  to   = module.shared_services_endpoints.aws_vpc_endpoint.interface["kms"]
}

moved {
  from = module.shared_services_vpc.aws_vpc_endpoint.interface["secretsmanager"]
  to   = module.shared_services_endpoints.aws_vpc_endpoint.interface["secretsmanager"]
}

moved {
  from = module.hybrid_connectivity.aws_security_group.resolver
  to   = module.dns_resolver.aws_security_group.resolver
}

moved {
  from = module.hybrid_connectivity.aws_route53_resolver_endpoint.inbound
  to   = module.dns_resolver.aws_route53_resolver_endpoint.inbound
}

moved {
  from = module.hybrid_connectivity.aws_route53_resolver_endpoint.outbound
  to   = module.dns_resolver.aws_route53_resolver_endpoint.outbound
}

moved {
  from = module.hybrid_connectivity.aws_route53_resolver_rule.forward["corp.example.com"]
  to   = module.dns_resolver.aws_route53_resolver_rule.forward["corp.example.com"]
}

moved {
  from = module.hybrid_connectivity.aws_customer_gateway.this[0]
  to   = module.vpn.aws_customer_gateway.this[0]
}

moved {
  from = module.hybrid_connectivity.aws_vpn_connection.this[0]
  to   = module.vpn.aws_vpn_connection.this[0]
}

moved {
  from = module.hybrid_connectivity.aws_dx_gateway.this
  to   = module.vpn.aws_dx_gateway.this[0]
}
