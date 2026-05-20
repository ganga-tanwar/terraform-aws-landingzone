# DNS Resolver Module

Provisions AWS Route53 Resolver endpoints for hybrid DNS resolution, enabling on-premises DNS domain forwarding from VPCs.

## Overview

This module creates Route53 Resolver infrastructure:
- **Inbound Endpoint**: Accepts DNS queries from on-premises
- **Outbound Endpoint**: Forwards VPC queries to on-premises DNS
- **Resolver Rules**: Routes specific domains to on-premises
- **VPC Associations**: Applies rules to VPCs

## Features

- ✅ Inbound and outbound endpoints
- ✅ DNS rule creation for domain routing
- ✅ VPC endpoint associations
- ✅ Availability across multiple AZs
- ✅ Logging to CloudWatch

## Usage

```hcl
module "dns_resolver" {
  source = "./modules/dns_resolver"

  # Inbound endpoint (on-premises → VPC)
  enable_inbound_endpoint = true
  inbound_subnet_ids      = module.vpc.app_subnet_ids
  
  # Outbound endpoint (VPC → on-premises)
  enable_outbound_endpoint = true
  outbound_subnet_ids      = module.vpc.app_subnet_ids
  
  # On-premises DNS servers
  on_prem_dns_servers = ["203.0.113.10"]
  
  # Domain forwarding rules
  resolver_rules = {
    "corp.example.com" = {
      rule_type = "FORWARD"
      targets   = ["203.0.113.10"]
    }
    "internal.company.local" = {
      rule_type = "FORWARD"
      targets   = ["203.0.113.11"]
    }
  }
  
  # VPC associations
  vpc_ids = [module.vpc.vpc_id]
  
  tags = {
    Environment = "prod"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `enable_inbound_endpoint` | Enable inbound endpoint | bool | true | no |
| `enable_outbound_endpoint` | Enable outbound endpoint | bool | true | no |
| `inbound_subnet_ids` | Subnets for inbound endpoint | list(string) | [] | no |
| `outbound_subnet_ids` | Subnets for outbound endpoint | list(string) | [] | no |
| `on_prem_dns_servers` | On-premises DNS server IPs | list(string) | [] | no |
| `resolver_rules` | DNS forwarding rules map | map(object) | {} | no |
| `vpc_ids` | VPCs to associate resolver rules | list(string) | [] | no |
| `tags` | Common tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| `inbound_endpoint_id` | Inbound endpoint ID |
| `outbound_endpoint_id` | Outbound endpoint ID |
| `resolver_rule_ids` | Map of resolver rule IDs |

---

**Last Updated**: 2026-05-20
