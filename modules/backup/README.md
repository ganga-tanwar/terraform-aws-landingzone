# Backup Module

Provisions AWS Backup infrastructure including backup vaults, backup plans, and cross-region backup replication for disaster recovery.

## Overview

This module creates backup infrastructure with:
- AWS Backup vaults per environment
- Daily backup plans with configurable schedules
- Automatic backup retention and lifecycle
- Cross-region backup replication for DR
- KMS encryption for backed-up data
- Tag-based resource selection

## Features

- ✅ Backup vaults with KMS encryption
- ✅ Daily backup plans (configurable schedule)
- ✅ Backup retention policies (30 days cold, 365 days total)
- ✅ Automatic backup lifecycle management
- ✅ Cross-region replication for DR
- ✅ Tag-based backup selection (BackupPolicy tag)
- ✅ Complete lifecycle and resource coverage
- ✅ Backup reports and monitoring

## Prerequisites

- Terraform >= 1.6
- AWS Backup service available
- EC2, EBS, RDS, or other supported resources to backup
- KMS keys for encryption (optional but recommended)

## Usage

```hcl
module "backup" {
  source = "./modules/backup"

  # Vault Configuration
  backup_vault_name          = "prod-backup-vault"
  environment                = "prod"
  
  # Encryption
  enable_kms_encryption      = true
  kms_key_id                 = aws_kms_key.backup.id
  
  # Backup Plan
  backup_plan_name           = "prod-daily-backup"
  backup_schedule            = "cron(0 5 ? * * *)"  # 5 AM UTC daily
  
  # Retention Policy
  backup_retention_days      = 30    # Cold storage
  backup_expiration_days     = 365   # Total retention
  
  # Resource Selection
  backup_resources = {
    ec2_instances = {
      resource_type = "EC2"
      tag_key       = "BackupPolicy"
      tag_value     = "daily"
    }
    ebs_volumes = {
      resource_type = "EBS"
      tag_key       = "BackupPolicy"
      tag_value     = "daily"
    }
  }
  
  # Disaster Recovery
  enable_cross_region_copy   = true
  copy_to_region             = "us-west-2"
  copy_vault_name            = "prod-backup-vault-dr"
  
  tags = {
    Environment = "prod"
    Application = "landing-zone"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `backup_vault_name` | Name of the backup vault | string | n/a | yes |
| `environment` | Environment name (dev/test/prod) | string | n/a | yes |
| `enable_kms_encryption` | Enable KMS encryption | bool | true | no |
| `kms_key_id` | KMS key ID for backup encryption | string | "" | no |
| `backup_plan_name` | Name of the backup plan | string | n/a | yes |
| `backup_schedule` | Cron schedule for backups | string | "cron(0 5 ? * * *)" | no |
| `backup_retention_days` | Days to retain backups in cold storage | number | 30 | no |
| `backup_expiration_days` | Total days before backup expires | number | 365 | no |
| `backup_resources` | Map of resources to backup | map(object) | {} | no |
| `enable_cross_region_copy` | Enable cross-region replication | bool | false | no |
| `copy_to_region` | Region to copy backups to | string | "us-west-2" | no |
| `copy_vault_name` | Name of DR backup vault | string | "" | no |
| `tags` | Common tags for all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| `backup_vault_id` | Backup vault ID |
| `backup_vault_arn` | Backup vault ARN |
| `backup_plan_id` | Backup plan ID |
| `backup_plan_arn` | Backup plan ARN |

## Backup Schedule

Default: **5 AM UTC daily** (configurable via `backup_schedule` parameter)

```cron
# Examples
cron(0 5 ? * * *)        # Daily at 5 AM UTC
cron(0 5 ? * MON *)      # Every Monday at 5 AM UTC
cron(0 5 1 * ? *)        # First day of month at 5 AM UTC
cron(0 2,5,8 ? * * *)    # 3 times daily (2 AM, 5 AM, 8 AM UTC)
```

## Retention Lifecycle

Backups follow this lifecycle:

```
Day 0-30: Active (Hot Storage)
  ↓ (immediately available, full recovery)
Day 30-365: Cold Storage (Glacier)
  ↓ (recovery takes 1-5 minutes)
Day 365+: Deleted
  (automatic expiration)
```

## Resource Tagging for Backup

Use the `BackupPolicy` tag to select resources:

```hcl
# EC2 instance with daily backup
resource "aws_instance" "app_server" {
  ami           = "ami-0c02fb55db3a0776b"
  instance_type = "t3.medium"
  
  tags = {
    Name          = "prod-app-server"
    BackupPolicy  = "daily"    # Triggers backup plan
    Environment   = "prod"
  }
}

# EBS volume without backup
resource "aws_ebs_volume" "temp_storage" {
  availability_zone = "us-east-2a"
  size              = 100
  
  tags = {
    Name = "temp-storage"
    # No BackupPolicy tag = not backed up
  }
}
```

## Cross-Region Backup Replication

For disaster recovery:

```hcl
module "backup_prod" {
  source = "./modules/backup"

  backup_vault_name          = "prod-backup-vault"
  environment                = "prod"
  
  # Enable DR replication
  enable_cross_region_copy   = true
  copy_to_region             = "us-west-2"
  copy_vault_name            = "prod-backup-vault-dr"
  
  # Replication inherits retention policy
  backup_retention_days      = 30
  backup_expiration_days     = 365
}

# In DR region, backups are automatically replicated
# Restore capability available immediately
```

## Example: Full Backup Configuration

```hcl
module "backup" {
  source = "./modules/backup"

  backup_vault_name          = "acmecorp-prod-backups"
  environment                = "prod"
  
  # Encryption at rest
  enable_kms_encryption      = true
  kms_key_id                 = aws_kms_key.backup.id
  
  backup_plan_name           = "acmecorp-prod-daily"
  backup_schedule            = "cron(0 5 ? * * *)"  # 5 AM UTC daily
  
  # Keep backups for 1 year
  backup_retention_days      = 30    # In Glacier after 30 days
  backup_expiration_days     = 365   # Deleted after 1 year
  
  # Backup tagged resources
  backup_resources = {
    ec2_instances = {
      resource_type = "EC2"
      tag_key       = "BackupPolicy"
      tag_value     = "daily"
    }
    rds_databases = {
      resource_type = "RDS"
      tag_key       = "BackupPolicy"
      tag_value     = "daily"
    }
    ebs_volumes = {
      resource_type = "EBS"
      tag_key       = "BackupPolicy"
      tag_value     = "daily"
    }
  }
  
  # DR replication to us-west-2
  enable_cross_region_copy   = true
  copy_to_region             = "us-west-2"
  copy_vault_name            = "acmecorp-prod-backups-dr"
  
  tags = {
    Environment  = "prod"
    Account      = "prod"
    Application  = "backup-plan"
    Owner        = "devops-team"
    BackupPolicy = "daily"
  }
}
```

## Recovery Scenarios

### Scenario 1: Restore EC2 Instance from Backup

```bash
# Get backup job ID
aws backup list-recovery-points-by-backup-vault \
  --backup-vault-name prod-backup-vault

# Create recovery job
aws backup start-recovery-point-restore \
  --recovery-point-arn arn:aws:backup:us-east-2:123456789012:recovery-point:...
```

### Scenario 2: Cross-Region Disaster Recovery

If us-east-2 region fails:

1. Backups are automatically replicated to us-west-2
2. Create new EC2 instances in us-west-2
3. Restore volumes from replicated backups
4. Update DNS to point to us-west-2

```hcl
# In us-west-2 (DR region)
module "backup_dr" {
  source = "./modules/backup"
  providers = {
    aws = aws.us_west_2
  }

  backup_vault_name = "prod-backup-vault-dr"
  # Backups are already here from cross-region replication
}
```

## Backup Monitoring

AWS Backup provides metrics and reports:

```bash
# Get backup job status
aws backup list-backup-jobs \
  --by-resource-type EC2 \
  --by-backup-vault-name prod-backup-vault

# Get recovery points
aws backup list-recovery-points-by-backup-vault \
  --backup-vault-name prod-backup-vault
```

## Cost Optimization

**Backup costs** vary by storage class and region:
- Active: $0.10/GB per month
- Cold: $0.03/GB per month
- DR replication: +$0.03/GB per month

**Optimize by:**
- Backing up only production resources
- Using appropriate retention (365 days typical)
- Transitioning to cold storage (30 days)
- Selective cross-region replication

## Dependencies

- Standalone module (no other module dependencies)
- Optional KMS key (can use AWS-managed keys)
- Works with multi-environment backup plans

## Resources Created

- `aws_backup_vault` — Backup vault
- `aws_backup_plan` — Backup plan with schedule
- `aws_backup_resource_assignment` — Resource selection rules
- `aws_backup_vault_lock_configuration` — Vault lock for compliance

## Notes

- **Tagging**: Ensure resources have `BackupPolicy` tag set to `daily`
- **Schedule**: Midnight UTC recommended to avoid business hours impact
- **Retention**: 365 days typical for compliance (SOX, HIPAA)
- **Cross-Region**: Enable immediately for production
- **Costs**: Monitor backup usage in AWS Cost Explorer

## Troubleshooting

**Issue: Backup jobs failing**
```bash
# Check backup job status
aws backup list-backup-jobs --by-backup-vault-name prod-backup-vault

# View job details
aws backup describe-backup-job --backup-job-id <job-id>
```

**Issue: Resources not being backed up**
- Verify resources have `BackupPolicy` tag with value `daily`
- Check backup plan resource assignment
- Ensure IAM role has permissions for resource type

**Issue: Cross-region copy not working**
- Verify destination vault exists in target region
- Check cross-region copy is enabled in plan
- Wait 24 hours for first copy to initiate

---

**Last Updated**: 2026-05-20  
**Terraform**: 1.6.0+  
**AWS Provider**: Latest stable
