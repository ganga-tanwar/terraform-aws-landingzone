# VPN Module

Provisions AWS Site-to-Site VPN connections through Transit Gateway for hybrid network connectivity to on-premises infrastructure.

## Overview

This module creates VPN infrastructure:
- Customer Gateway (on-premises VPN endpoint)
- Virtual Private Gateway (AWS side)
- VPN Connection (Site-to-Site VPN)
- Transit Gateway attachments
- Route propagation

## Usage

```hcl
module "vpn" {
  source = "./modules/vpn"

  # On-premises VPN endpoint
  customer_gateway_ip = "203.0.113.1"
  
  # Transit Gateway
  transit_gateway_id = module.transit_gateway.transit_gateway_id
  
  # Tags
  tags = {
    Environment = "prod"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `customer_gateway_ip` | On-premises VPN public IP | string | n/a | yes |
| `transit_gateway_id` | Transit Gateway ID | string | n/a | yes |
| `tags` | Common tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| `vpn_connection_id` | VPN connection ID |
| `customer_gateway_id` | Customer gateway ID |

---

**Last Updated**: 2026-05-20
