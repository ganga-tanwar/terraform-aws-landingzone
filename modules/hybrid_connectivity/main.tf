resource "aws_security_group" "resolver" {
  name_prefix = "${var.name_prefix}-resolver-"
  description = "Route53 Resolver endpoint security group"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name_prefix}-resolver-sg" })

  ingress {
    description = "DNS TCP from on-premises"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = var.on_premises_cidrs
  }

  ingress {
    description = "DNS UDP from on-premises"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = var.on_premises_cidrs
  }

  egress {
    description = "DNS TCP to on-premises"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = var.on_premises_cidrs
  }

  egress {
    description = "DNS UDP to on-premises"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = var.on_premises_cidrs
  }
}

resource "aws_route53_resolver_endpoint" "inbound" {
  name      = "${var.name_prefix}-inbound"
  direction = "INBOUND"

  security_group_ids = [aws_security_group.resolver.id]

  dynamic "ip_address" {
    for_each = var.subnet_ids
    content {
      subnet_id = ip_address.value
    }
  }

  tags = var.tags
}

resource "aws_route53_resolver_endpoint" "outbound" {
  name      = "${var.name_prefix}-outbound"
  direction = "OUTBOUND"

  security_group_ids = [aws_security_group.resolver.id]

  dynamic "ip_address" {
    for_each = var.subnet_ids
    content {
      subnet_id = ip_address.value
    }
  }

  tags = var.tags
}

resource "aws_route53_resolver_rule" "forward" {
  for_each = var.dns_forward_domains

  domain_name          = each.key
  name                 = replace(each.key, ".", "-")
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound.id

  dynamic "target_ip" {
    for_each = each.value
    content {
      ip = target_ip.value
    }
  }

  tags = var.tags
}

resource "aws_customer_gateway" "this" {
  count = var.customer_gateway_ip == null ? 0 : 1

  bgp_asn    = var.customer_gateway_bgp_asn
  ip_address = var.customer_gateway_ip
  type       = "ipsec.1"
  tags       = merge(var.tags, { Name = "${var.name_prefix}-cgw" })
}

resource "aws_vpn_connection" "this" {
  count = var.customer_gateway_ip == null ? 0 : 1

  customer_gateway_id = aws_customer_gateway.this[0].id
  transit_gateway_id  = var.transit_gateway_id
  type                = "ipsec.1"
  static_routes_only  = false
  tags                = merge(var.tags, { Name = "${var.name_prefix}-vpn" })
}

resource "aws_dx_gateway" "this" {
  name            = "${var.name_prefix}-dxgw"
  amazon_side_asn = var.direct_connect_gateway_asn
}
