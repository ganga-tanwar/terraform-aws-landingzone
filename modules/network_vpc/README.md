# Network VPC Module

Provisions VPC infrastructure including subnets, route tables, internet gateways, and network access control lists across multiple availability zones.

## Overview

This module creates a complete VPC with:
- Multi-AZ subnet architecture (public, application, database)
- Internet Gateway for public internet access
- Route tables and routes for network traffic
- Network ACLs for stateless firewall rules
- VPC Flow Logs for traffic monitoring
- DNS configuration and DHCP options

## Features

- ✅ VPC with configurable CIDR block
- ✅ Multi-AZ subnets (3 AZs default for production)
- ✅ Public, private app, and private database subnets per AZ
- ✅ Internet Gateway with public routes
- ✅ VPC Flow Logs to S3 for traffic analysis
- ✅ Network ACLs with preconfigured rules
- ✅ DNS hostnames and DNS resolution enabled
- ✅ VPC endpoints integration (Gateway and Interface)

## Prerequisites

- Terraform >= 1.6
- AWS VPC service available in target region
- S3 bucket for VPC Flow Logs (if enabled)
- KMS key for Flow Logs encryption (optional)

## Usage

```hcl
module "network_vpc" {
  source = "./modules/network_vpc"

  # VPC Configuration
  vpc_name            = "prod-vpc"
  vpc_cidr            = "10.30.0.0/16"
  environment         = "prod"
  availability_zones  = ["us-east-2a", "us-east-2b", "us-east-2c"]
  
  # Subnet Configuration
  public_subnet_cidrs     = ["10.30.1.0/24", "10.30.2.0/24", "10.30.3.0/24"]
  app_subnet_cidrs        = ["10.30.11.0/24", "10.30.12.0/24", "10.30.13.0/24"]
  database_subnet_cidrs   = ["10.30.21.0/24", "10.30.22.0/24", "10.30.23.0/24"]
  
  # Features
  enable_nat_gateway = true
  enable_vpc_flow_logs = true
  
  # Flow Logs
  flow_logs_bucket = "my-flow-logs-bucket"
  flow_logs_prefix = "vpc-flow-logs/"
  
  # Tags
  tags = {
    Environment = "prod"
    Application = "landing-zone"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `vpc_name` | Name of the VPC | string | n/a | yes |
| `vpc_cidr` | CIDR block for the VPC | string | n/a | yes |
| `environment` | Environment name (dev/test/prod) | string | n/a | yes |
| `availability_zones` | List of AZs to use | list(string) | ["us-east-2a", "us-east-2b", "us-east-2c"] | no |
| `public_subnet_cidrs` | CIDR blocks for public subnets | list(string) | n/a | yes |
| `app_subnet_cidrs` | CIDR blocks for app subnets | list(string) | n/a | yes |
| `database_subnet_cidrs` | CIDR blocks for database subnets | list(string) | n/a | yes |
| `enable_nat_gateway` | Enable NAT Gateways for private subnets | bool | true | no |
| `enable_vpc_flow_logs` | Enable VPC Flow Logs | bool | true | no |
| `flow_logs_bucket` | S3 bucket for VPC Flow Logs | string | "" | no |
| `flow_logs_prefix` | S3 prefix for Flow Logs | string | "vpc-flow-logs/" | no |
| `enable_dns_hostnames` | Enable DNS hostnames | bool | true | no |
| `enable_dns_resolution` | Enable DNS resolution | bool | true | no |
| `tags` | Common tags for all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | VPC ID |
| `vpc_cidr` | VPC CIDR block |
| `public_subnet_ids` | List of public subnet IDs |
| `app_subnet_ids` | List of app subnet IDs |
| `database_subnet_ids` | List of database subnet IDs |
| `internet_gateway_id` | Internet Gateway ID |
| `nat_gateway_ids` | List of NAT Gateway IDs |
| `nat_gateway_eips` | Elastic IPs for NAT Gateways |

## Subnet Architecture

Each VPC includes three types of subnets per AZ:

```
VPC (10.30.0.0/16)
├── AZ-1 (us-east-2a)
│   ├── Public Subnet (10.30.1.0/24) → Internet Gateway
│   ├── App Subnet (10.30.11.0/24) → NAT Gateway → IGW
│   └── Database Subnet (10.30.21.0/24) → No internet
├── AZ-2 (us-east-2b)
│   ├── Public Subnet (10.30.2.0/24)
│   ├── App Subnet (10.30.12.0/24)
│   └── Database Subnet (10.30.22.0/24)
└── AZ-3 (us-east-2c)
    ├── Public Subnet (10.30.3.0/24)
    ├── App Subnet (10.30.13.0/24)
    └── Database Subnet (10.30.23.0/24)
```

## Routing

- **Public Subnet**: Routes default traffic (0.0.0.0/0) to IGW
- **App Subnet**: Routes default traffic to NAT Gateway (in same AZ)
- **Database Subnet**: No route to internet (isolated)

## VPC Flow Logs

Captures network traffic metadata for all ENIs in the VPC:

```hcl
# Example Flow Log entry
version account-id interface-id srcaddr dstaddr srcport dstport protocol packets bytes
2 123456789012 eni-abcdef01 10.30.1.5 10.30.11.5 443 49152 6 25 12000

# Log to S3
# s3://my-flow-logs-bucket/vpc-flow-logs/AWSLogs/123456789012/vpcflowlogs/...
```

## Example: Development VPC (Single AZ, Cost Optimized)

```hcl
module "dev_vpc" {
  source = "./modules/network_vpc"

  vpc_name           = "dev-vpc"
  vpc_cidr           = "10.10.0.0/16"
  environment        = "dev"
  availability_zones = ["us-east-2a"]  # Single AZ for cost
  
  public_subnet_cidrs   = ["10.10.1.0/24"]
  app_subnet_cidrs      = ["10.10.11.0/24"]
  database_subnet_cidrs = ["10.10.21.0/24"]
  
  enable_nat_gateway   = true  # Still needed for private subnet outbound
  enable_vpc_flow_logs = true
  
  flow_logs_bucket = aws_s3_bucket.logs.id
  
  tags = {
    Environment = "dev"
    CostCenter  = "engineering"
  }
}
```

## Dependencies

- Requires S3 bucket for Flow Logs (if enabled)
- Requires KMS key for Flow Logs encryption (if using KMS)
- Standalone module (no module dependencies)

## Resources Created

- `aws_vpc` — VPC
- `aws_subnet` — Public, app, and database subnets (3 per AZ)
- `aws_internet_gateway` — IGW attachment
- `aws_route_table` — Route tables for each subnet type
- `aws_route` — Routes for IGW and NAT traffic
- `aws_flow_log` — VPC Flow Logs
- `aws_network_acl` — Network ACLs with inbound/outbound rules
- `aws_vpc_dhcp_options` — DHCP options for DNS

## Notes

- **Multi-AZ**: Recommended for production (HA resilience)
- **Single-AZ**: Acceptable for dev/test (cost savings)
- **Flow Logs**: Enable immediately for security monitoring
- **Subnet Sizing**: /24 subnets support ~250 IP addresses each
- **Route Priority**: More specific routes take precedence

## Troubleshooting

**Issue: Elastic IPs exhausted**
```bash
# Check EIP usage
aws ec2 describe-addresses | grep -c "AssociationId"
```

**Issue: Subnets not routing traffic**
- Verify route table associations
- Check security group egress rules
- Verify Network ACL rules

**Issue: VPC Flow Logs not appearing in S3**
- Check IAM role permissions for Flow Logs service
- Verify S3 bucket policy allows flow logs writing
- Wait 5-10 minutes for first logs to appear

---

**Last Updated**: 2026-05-20  
**Terraform**: 1.6.0+  
**AWS Provider**: Latest stable
