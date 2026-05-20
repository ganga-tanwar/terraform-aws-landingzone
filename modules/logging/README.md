# Logging Module

Provisions centralized S3 logging infrastructure for collecting logs from CloudTrail, AWS Config, VPC Flow Logs, and other AWS services with encryption, versioning, and lifecycle policies.

## Overview

This module creates a secure, centralized logging bucket with:
- KMS encryption at rest
- Versioning for log retention
- MFA delete for additional protection
- Lifecycle policies for cost optimization
- Block public access configuration
- Logging bucket for access logs

## Features

- ✅ S3 bucket with enforced encryption
- ✅ Versioning enabled for audit trails
- ✅ MFA delete for protective compliance
- ✅ Block all public access settings
- ✅ Lifecycle transitions (Standard → Glacier → Deep Archive)
- ✅ Bucket replication for DR (optional)
- ✅ Access logging to secondary bucket
- ✅ Bucket policies for CloudTrail, Config, VPC Flow Logs

## Prerequisites

- Terraform >= 1.6
- AWS KMS service available
- S3 service available
- IAM permissions for bucket and KMS operations

## Usage

```hcl
module "logging" {
  source = "./modules/logging"

  # Bucket Configuration
  log_bucket_name      = "org-logs-${data.aws_caller_identity.current.account_id}"
  environment          = "prod"
  
  # Encryption
  enable_kms_encryption = true
  kms_master_key_id    = aws_kms_key.logs.id
  
  # Versioning & Retention
  enable_versioning           = true
  enable_mfa_delete           = true  # Requires MFA for version deletion
  
  # Lifecycle Policy
  transition_to_glacier_days  = 90
  transition_to_deeparchive_days = 365
  expiration_days            = 2555  # 7 years
  
  # Replication (Optional, for DR)
  enable_replication          = false
  replica_bucket_name         = "org-logs-dr-${data.aws_caller_identity.current.account_id}"
  replica_bucket_region       = "us-west-2"
  
  # Access Logging
  enable_access_logging       = true
  access_log_prefix           = "access-logs/"
  
  # Permissions
  allow_cloudtrail           = true
  allow_config               = true
  allow_vpc_flow_logs        = true
  
  tags = {
    Environment = "prod"
    Application = "landing-zone"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `log_bucket_name` | Name of the main logging bucket | string | n/a | yes |
| `environment` | Environment name (dev/test/prod) | string | n/a | yes |
| `enable_kms_encryption` | Enable KMS encryption | bool | true | no |
| `kms_master_key_id` | KMS key ID for encryption | string | "" | no |
| `enable_versioning` | Enable S3 versioning | bool | true | no |
| `enable_mfa_delete` | Require MFA for version deletion | bool | true | no |
| `transition_to_glacier_days` | Days before transition to Glacier | number | 90 | no |
| `transition_to_deeparchive_days` | Days before transition to Deep Archive | number | 365 | no |
| `expiration_days` | Days before object expiration | number | 2555 | no |
| `enable_replication` | Enable cross-region replication | bool | false | no |
| `replica_bucket_region` | Region for replica bucket | string | "us-west-2" | no |
| `enable_access_logging` | Enable access logging | bool | true | no |
| `allow_cloudtrail` | Allow CloudTrail to write logs | bool | true | no |
| `allow_config` | Allow AWS Config to write logs | bool | true | no |
| `allow_vpc_flow_logs` | Allow VPC Flow Logs | bool | true | no |
| `tags` | Common tags for all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| `log_bucket_id` | Main logging bucket ID |
| `log_bucket_arn` | Main logging bucket ARN |
| `access_log_bucket_id` | Access logging bucket ID |
| `kms_key_id` | KMS key ID for encryption |
| `kms_key_arn` | KMS key ARN |

## S3 Lifecycle Policy

Logs are automatically transitioned through storage classes for cost optimization:

```
Day 0-90: S3 Standard
  ↓ (frequently accessed, full analysis)
Day 90-365: S3 Glacier Flexible Retrieval
  ↓ (occasional access, compliance holds)
Day 365+: S3 Deep Archive
  ↓ (rare access, long-term compliance)
Day 2555: Deleted
  (7-year retention complete)
```

**Cost Impact:**
- Standard: $0.023/GB per month
- Glacier: $0.004/GB per month (80% savings)
- Deep Archive: $0.00099/GB per month (95% savings)

## Bucket Structure

```
s3://org-logs-123456789012/
├── cloudtrail/                     # CloudTrail logs
│   └── AWSLogs/123456789012/CloudTrail/us-east-2/...
├── config/                         # AWS Config snapshots
│   └── AWSLogs/123456789012/Config/...
├── vpc-flow-logs/                  # VPC Flow Logs
│   └── AWSLogs/123456789012/vpcflowlogs/us-east-2/...
└── access-logs/                    # S3 access logs
    └── 2026-05-20-XX-XX-XX-XXXXX
```

## Bucket Policies

This module automatically creates bucket policies to allow:
- CloudTrail delivery (if enabled)
- AWS Config delivery (if enabled)
- VPC Flow Logs delivery (if enabled)

```json
{
  "Effect": "Allow",
  "Principal": {
    "Service": "cloudtrail.amazonaws.com"
  },
  "Action": "s3:PutObject",
  "Resource": "arn:aws:s3:::org-logs-*/*"
}
```

## Example: Multi-Account Logging Setup

```hcl
# In Log Archive Account (centralized)
module "logging" {
  source = "./modules/logging"

  log_bucket_name             = "acmecorp-logs-${data.aws_caller_identity.current.account_id}"
  environment                 = "prod"
  
  enable_kms_encryption       = true
  kms_master_key_id           = aws_kms_key.logs.id
  
  enable_versioning           = true
  enable_mfa_delete           = true
  
  # Transition to Glacier after 90 days for cost
  transition_to_glacier_days  = 90
  transition_to_deeparchive_days = 365
  expiration_days             = 2555  # 7 years
  
  # DR Replication to us-west-2
  enable_replication          = true
  replica_bucket_region       = "us-west-2"
  
  # Allow all log sources
  allow_cloudtrail            = true
  allow_config                = true
  allow_vpc_flow_logs         = true
  
  tags = {
    Environment = "prod"
    Account     = "log-archive"
    CostCenter  = "security"
  }
}

# Output for cross-account references
output "log_bucket_arn" {
  value = module.logging.log_bucket_arn
}
```

## Cross-Account Logging

Allow other accounts to write logs to centralized bucket:

```hcl
# In Log Archive Account
resource "aws_s3_bucket_policy" "cross_account" {
  bucket = module.logging.log_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${var.dev_account_id}:root",
            "arn:aws:iam::${var.prod_account_id}:root"
          ]
        }
        Action   = ["s3:PutObject"]
        Resource = "${module.logging.log_bucket_arn}/*"
      }
    ]
  })
}
```

## KMS Encryption

Logs are encrypted with customer-managed KMS keys:

```hcl
# KMS key for logs
resource "aws_kms_key" "logs" {
  description             = "Encryption key for log bucket"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

# KMS key policy allows CloudTrail and Config
# (handled by module)
```

## Dependencies

- Standalone module (no other module dependencies)
- Optional KMS key (can use AWS-managed keys)
- Works with multi-account logging (requires cross-account permissions)

## Resources Created

- `aws_s3_bucket` — Main logging bucket
- `aws_s3_bucket` — Access logging bucket
- `aws_s3_bucket_versioning` — Enable versioning
- `aws_s3_bucket_lifecycle_configuration` — Lifecycle transitions
- `aws_s3_bucket_public_access_block` — Block public access
- `aws_s3_bucket_policy` — Policies for log delivery
- `aws_s3_bucket_replication_configuration` — Cross-region replication
- `aws_kms_key` — Encryption key (optional)
- `aws_kms_key_policy` — KMS key policy

## Notes

- **Versioning**: Enables compliance hold on logs (can't be deleted without MFA)
- **MFA Delete**: Requires MFA token to delete/overwrite objects
- **Lifecycle**: Transition timeline balances accessibility vs. cost
- **Replication**: For DR, replicate to secondary region
- **Access Logs**: Enable to track who accesses the log bucket itself

## Troubleshooting

**Issue: CloudTrail can't deliver logs**
```bash
# Check bucket policy
aws s3api get-bucket-policy --bucket org-logs-123456789012

# Verify CloudTrail service role permissions
```

**Issue: Objects not transitioning to Glacier**
- Check lifecycle rule is enabled
- Verify object is older than transition days
- Note: Can take 24 hours for transition

**Issue: Replication not working**
- Verify replica bucket exists
- Check replication IAM role permissions
- Enable replication on source bucket and sync

---

**Last Updated**: 2026-05-20  
**Terraform**: 1.6.0+  
**AWS Provider**: Latest stable
