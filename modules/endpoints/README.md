# VPC Endpoints Module

Provisions AWS VPC Endpoints (Gateway and Interface types) to enable private connectivity to AWS services without routing traffic through the internet.

## Overview

This module creates VPC endpoints for:
- **Gateway Endpoints**: S3 and DynamoDB (no charge, no ENI required)
- **Interface Endpoints**: AWS services (CloudWatch, SNS, SQS, Secrets Manager, etc.)
- **Endpoint policies**: Restrict service access
- **Route table integration**: Automatic routing for gateway endpoints
- **DNS resolution**: Private DNS names for interface endpoints

## Features

- ✅ Gateway endpoints (S3, DynamoDB) with route table integration
- ✅ Interface endpoints for AWS services
- ✅ Private DNS name resolution
- ✅ Security group attachment for interface endpoints
- ✅ Endpoint-specific bucket policies
- ✅ VPC endpoint service discovery

## Prerequisites

- Terraform >= 1.6
- VPC already created
- Private subnets for interface endpoints

## Usage

```hcl
module "vpc_endpoints" {
  source = "./modules/endpoints"

  vpc_id             = aws_vpc.main.id
  subnet_ids         = aws_subnet.private_app[*].id
  
  # Gateway Endpoints (S3, DynamoDB)
  enable_s3_endpoint        = true
  enable_dynamodb_endpoint  = true
  s3_route_table_ids        = [aws_route_table.private.id]
  
  # Interface Endpoints
  enable_interface_endpoints = true
  interface_endpoint_services = [
    "ec2",
    "elasticloadbalancing",
    "sns",
    "sqs",
    "secretsmanager",
    "ssm",
    "logs"
  ]
  
  # Security
  create_endpoint_security_group = true
  allowed_security_groups        = [aws_security_group.private.id]
  
  tags = {
    Environment = "prod"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `vpc_id` | VPC ID | string | n/a | yes |
| `subnet_ids` | Subnet IDs for interface endpoints | list(string) | [] | no |
| `enable_s3_endpoint` | Enable S3 gateway endpoint | bool | true | no |
| `enable_dynamodb_endpoint` | Enable DynamoDB gateway endpoint | bool | true | no |
| `s3_route_table_ids` | Route table IDs for S3 endpoint | list(string) | [] | no |
| `enable_interface_endpoints` | Enable interface endpoints | bool | true | no |
| `interface_endpoint_services` | List of services for interface endpoints | list(string) | [] | no |
| `create_endpoint_security_group` | Create security group for endpoints | bool | true | no |
| `allowed_security_groups` | Security groups allowed to use endpoints | list(string) | [] | no |
| `tags` | Common tags for all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| `s3_endpoint_id` | S3 endpoint ID |
| `dynamodb_endpoint_id` | DynamoDB endpoint ID |
| `interface_endpoint_ids` | Map of interface endpoint IDs |
| `endpoint_security_group_id` | Security group for endpoints |

## Gateway vs Interface Endpoints

| Feature | Gateway | Interface |
|---------|---------|-----------|
| **Services** | S3, DynamoDB | Most AWS services |
| **Cost** | Free | $7.20/month + data |
| **ENI** | No | Yes (per AZ) |
| **DNS** | No | Yes (private) |
| **Route Table** | Yes | No (uses DNS) |
| **Security Group** | No | Yes |

## Example: Full Endpoint Setup

```hcl
module "vpc_endpoints" {
  source = "./modules/endpoints"

  vpc_id     = module.network_vpc.vpc_id
  subnet_ids = module.network_vpc.app_subnet_ids
  
  # Gateway endpoints
  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true
  s3_route_table_ids       = [
    module.network_vpc.private_app_route_table_id,
    module.network_vpc.private_db_route_table_id
  ]
  
  # Interface endpoints
  enable_interface_endpoints = true
  interface_endpoint_services = [
    "ec2",
    "ec2messages",
    "ssm",
    "ssmmessages",
    "logs",
    "monitoring",
    "sns",
    "sqs",
    "secretsmanager",
    "kms"
  ]
  
  # Security
  create_endpoint_security_group = true
  allowed_security_groups = [
    module.network_vpc.application_security_group_id
  ]
  
  tags = {
    Environment = "prod"
  }
}
```

## Resources Created

- `aws_vpc_endpoint` — S3 gateway endpoint
- `aws_vpc_endpoint` — DynamoDB gateway endpoint
- `aws_vpc_endpoint` — Interface endpoints
- `aws_vpc_endpoint_route_table_association` — Route table associations
- `aws_security_group` — Endpoint security group

---

**Last Updated**: 2026-05-20
