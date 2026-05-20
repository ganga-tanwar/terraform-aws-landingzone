# Transit Gateway Module

Provisions AWS Transit Gateway infrastructure for hub-and-spoke network topology, enabling centralized routing between VPCs and on-premises networks.

## Overview

This module creates an AWS Transit Gateway with:
- Transit Gateway hub for centralized routing
- DNS support for hybrid DNS resolution
- Resource sharing via AWS RAM for multi-account access
- VPN ECMP support for redundant VPN connections
- Auto-accept shared attachments for seamless integration

## Features

- ✅ Transit Gateway with DNS support enabled
- ✅ VPN ECMP support for redundancy
- ✅ Auto-accept shared attachments
- ✅ AWS Resource Access Manager (RAM) integration
- ✅ Default route table for attachments
- ✅ Multi-account attachment support

## Prerequisites

- Terraform >= 1.6
- AWS provider with appropriate permissions
- Transit Gateway service available in target region
- VPCs or VPN connections to attach

## Usage

```hcl
module "transit_gateway" {
  source = "./modules/transit_gateway"

  # Transit Gateway Configuration
  tgw_name            = "enterprise-lz-tgw"
  description         = "Hub for enterprise landing zone"
  
  # Features
  enable_dns_support           = true
  enable_vpn_ecmp_support      = true
  enable_auto_accept_shared_attachments = true
  
  # Resource Sharing (for multi-account access)
  enable_resource_sharing      = true
  shared_principal_arns        = ["arn:aws:iam::123456789012:root"]  # Other account roots
  
  tags = {
    Environment = "prod"
    Application = "landing-zone"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `tgw_name` | Name of the Transit Gateway | string | n/a | yes |
| `description` | Description of the Transit Gateway | string | "" | no |
| `enable_dns_support` | Enable DNS support | bool | true | no |
| `enable_vpn_ecmp_support` | Enable VPN ECMP (equal-cost multi-path) | bool | true | no |
| `enable_auto_accept_shared_attachments` | Auto-accept shared VPC attachments | bool | true | no |
| `enable_resource_sharing` | Enable AWS RAM sharing | bool | true | no |
| `shared_principal_arns` | ARNs of principals to share TGW with | list(string) | [] | no |
| `default_route_table_association` | Enable default route table association | bool | true | no |
| `default_route_table_propagation` | Enable default route table propagation | bool | true | no |
| `tags` | Common tags for all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| `transit_gateway_id` | Transit Gateway ID (tgw-xxxxxxxx) |
| `transit_gateway_arn` | Transit Gateway ARN |
| `transit_gateway_route_table_id` | Default route table ID |
| `ram_resource_share_id` | RAM resource share ID (if sharing enabled) |

## Hub-and-Spoke Architecture

```
┌─────────────────────────────────────────────┐
│         AWS Transit Gateway Hub             │
│        (enterprise-lz-tgw in us-east-2)     │
└─────────────────────────────────────────────┘
        ↓             ↓              ↓
    ┌──────────┐ ┌──────────┐ ┌──────────┐
    │ Shared   │ │ Dev/Test │ │  Prod    │
    │ Services │ │   VPCs   │ │   VPC    │
    │   VPC    │ │ (10.10/) │ │ (10.30/) │
    │(10.0.0/) │ │(10.20/)  │ │          │
    └──────────┘ └──────────┘ └──────────┘
        ↓ (optional)
    ┌──────────────────────────────────────┐
    │    On-Premises Network (VPN)        │
    │    via Site-to-Site VPN Connection  │
    └──────────────────────────────────────┘
```

## VPC Attachment

VPCs attach to the Transit Gateway to communicate through the hub:

```hcl
# Typically defined in network_vpc module or separately
resource "aws_ec2_transit_gateway_vpc_attachment" "shared_services" {
  transit_gateway_id = module.transit_gateway.transit_gateway_id
  vpc_id             = module.shared_services_vpc.vpc_id
  subnet_ids         = module.shared_services_vpc.app_subnet_ids
  
  tags = {
    Name = "tgw-attachment-shared-services"
  }
}
```

## Multi-Account Sharing (AWS RAM)

Enable other AWS accounts to attach their VPCs to this Transit Gateway:

```hcl
# Account A (Network/Hub Account)
module "transit_gateway" {
  source = "./modules/transit_gateway"
  
  enable_resource_sharing = true
  # Share with other account roots
  shared_principal_arns = [
    "arn:aws:iam::111111111111:root",  # Dev account
    "arn:aws:iam::222222222222:root",  # Prod account
  ]
}

# Account B (Dev Account) - can now attach VPCs to shared TGW
resource "aws_ec2_transit_gateway_vpc_attachment" "dev_vpc" {
  transit_gateway_id = "tgw-xxxxxxxx"  # From shared TGW
  vpc_id             = aws_vpc.dev.id
  subnet_ids         = [aws_subnet.dev_app.id]
}
```

## VPN Connection

For hybrid connectivity:

```hcl
# Create Transit Gateway attachment for VPN
resource "aws_ec2_transit_gateway_route_table" "vpn" {
  transit_gateway_id = module.transit_gateway.transit_gateway_id
  
  tags = {
    Name = "vpn-route-table"
  }
}

# Attach VPN connection
resource "aws_ec2_transit_gateway_vpn_attachment" "vpn" {
  transit_gateway_id      = module.transit_gateway.transit_gateway_id
  customer_gateway_id     = aws_customer_gateway.on_prem.id
  vpn_gateway_id          = aws_vpn_gateway.aws.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpn.id
}
```

## Routing Configuration

Default route table propagation enables automatic route learning:

```hcl
# Enable propagation from all attachments
resource "aws_ec2_transit_gateway_route_table_propagation" "shared_services" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared_services.id
  transit_gateway_route_table_id = module.transit_gateway.transit_gateway_route_table_id
}
```

## Example: Full Multi-Account Setup

```hcl
# In Network Account (central hub)
module "transit_gateway" {
  source = "./modules/transit_gateway"

  tgw_name            = "enterprise-lz-hub"
  description         = "Central hub for enterprise landing zone"
  
  enable_dns_support                     = true
  enable_vpn_ecmp_support                = true
  enable_auto_accept_shared_attachments = true
  enable_resource_sharing                = true
  
  # Share with Dev, Test, Prod accounts
  shared_principal_arns = [
    "arn:aws:iam::${var.dev_account_id}:root",
    "arn:aws:iam::${var.test_account_id}:root",
    "arn:aws:iam::${var.prod_account_id}:root",
  ]
  
  tags = {
    Environment = "prod"
    Application = "landing-zone"
    Centralized = "true"
  }
}

output "tgw_id" {
  value = module.transit_gateway.transit_gateway_id
}

output "tgw_arn" {
  value = module.transit_gateway.transit_gateway_arn
}
```

## Dependencies

- Requires Transit Gateway service in target region
- Standalone module (no other module dependencies)
- VPCs/VPN connections attach after TGW creation

## Resources Created

- `aws_ec2_transit_gateway` — Transit Gateway
- `aws_ec2_transit_gateway_route_table` — Default route table
- `aws_ram_resource_share` — Resource share (if sharing enabled)
- `aws_ram_principal_association` — Principal access (if sharing enabled)

## DNS Resolution in Hybrid Environments

With DNS support enabled, VPCs can resolve on-premises DNS via Route53 Resolver:

```
VPC App Server
      ↓ (queries corp.example.com)
Route53 Resolver Endpoint (in Shared Services VPC)
      ↓ (forwards to on-premises DNS)
Transit Gateway VPN Attachment
      ↓ (VPN tunnel to on-premises)
On-Premises DNS Server
      ↓ (responds with IP)
```

## Notes

- **DNS Support**: Enable if using hybrid DNS or Route53 Resolver
- **VPN ECMP**: Enables multiple simultaneous VPN connections for redundancy
- **Auto-Accept**: Reduces manual approval steps in multi-account setups
- **Propagation**: Default route table automatically learns routes from attachments
- **Monitoring**: Use Transit Gateway Flow Logs to monitor routing

## Troubleshooting

**Issue: VPC attachment fails**
```bash
# Check attachment status
aws ec2 describe-transit_gateway_attachments \
  --filters "Name=transit-gateway-id,Values=tgw-xxxxxxxx"
```

**Issue: Routes not propagating**
- Verify attachment is in `available` state
- Check route table propagation is enabled
- Review security groups and NACLs

**Issue: Cross-account attachment fails**
- Verify RAM share is accepted in target account
- Check IAM permissions for cross-account access

---

**Last Updated**: 2026-05-20  
**Terraform**: 1.6.0+  
**AWS Provider**: Latest stable
