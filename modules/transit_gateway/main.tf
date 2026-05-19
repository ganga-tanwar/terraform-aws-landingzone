resource "aws_ec2_transit_gateway" "this" {
  description                     = var.name
  amazon_side_asn                 = var.asn
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"
  auto_accept_shared_attachments  = "enable"

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_ram_resource_share" "this" {
  count = length(var.share_with_principal_arns) > 0 ? 1 : 0

  name                      = "${var.name}-share"
  allow_external_principals = false
  tags                      = var.tags
}

resource "aws_ram_resource_association" "this" {
  count = length(var.share_with_principal_arns) > 0 ? 1 : 0

  resource_arn       = aws_ec2_transit_gateway.this.arn
  resource_share_arn = aws_ram_resource_share.this[0].arn
}

resource "aws_ram_principal_association" "this" {
  for_each = var.share_with_principal_arns

  principal          = each.value
  resource_share_arn = aws_ram_resource_share.this[0].arn
}
