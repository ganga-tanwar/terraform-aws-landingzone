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
  count = var.create_direct_connect_gateway ? 1 : 0

  name            = "${var.name_prefix}-dxgw"
  amazon_side_asn = var.direct_connect_gateway_asn
}
