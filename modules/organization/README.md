# Organization Module

Provisions and manages AWS Organizations infrastructure including organizational units (OUs), AWS accounts, and service control policies (SCPs).

## Overview

This module creates a complete AWS Organizations setup with:
- Root organization management
- Organizational Units (OUs) for account grouping
- AWS Accounts with automated provisioning
- Service Control Policies for governance
- Cross-account IAM role trust relationships

## Features

- ✅ Automatic AWS Organization creation (or detection of existing)
- ✅ Dynamic OU structure (Security, Infrastructure, Workloads, Sandbox)
- ✅ Account creation automation with email delegation
- ✅ 4 service control policies (CloudTrail protection, S3 blocking, region restriction, root restriction)
- ✅ SCP attachment to appropriate OUs
- ✅ Enable all AWS services integration (e.g., CloudTrail, AWS Config)

## Prerequisites

- Terraform >= 1.6
- AWS Account with Organizations enabled or ability to enable it
- Appropriate IAM permissions (`organizations:*`)
- Email addresses for each AWS account to be created

## Usage

```hcl
module "organization" {
  source = "./modules/organization"

  # Organization settings
  organization_enabled  = true
  organization_name     = "MyCompany"
  
  # AWS Accounts to create
  aws_accounts = {
    log_archive = {
      name  = "Log Archive Account"
      email = "logs@mycompany.com"
    }
    security_tooling = {
      name  = "Security Tooling Account"
      email = "security@mycompany.com"
    }
    network = {
      name  = "Network Account"
      email = "network@mycompany.com"
    }
    shared_services = {
      name  = "Shared Services Account"
      email = "shared-services@mycompany.com"
    }
    dev = {
      name  = "Development Account"
      email = "dev@mycompany.com"
    }
    test = {
      name  = "Testing Account"
      email = "test@mycompany.com"
    }
    prod = {
      name  = "Production Account"
      email = "prod@mycompany.com"
    }
  }
  
  # SCPs to enable
  enable_scp_cloudtrail_protection = true
  enable_scp_s3_blocking           = true
  enable_scp_region_restriction    = true
  enable_scp_root_restriction      = true
  
  # Allowed regions for SCP
  allowed_regions = ["us-east-2", "us-west-2"]
  
  # Tags
  tags = {
    Environment = "prod"
    Application = "landing-zone"
    Owner       = "devops"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `organization_enabled` | Whether to create AWS Organization | bool | true | yes |
| `organization_name` | Name of the organization | string | n/a | yes |
| `aws_accounts` | Map of AWS accounts to create | map(object) | {} | no |
| `enable_scp_cloudtrail_protection` | Enable SCP to prevent CloudTrail disabling | bool | true | no |
| `enable_scp_s3_blocking` | Enable SCP to block public S3 access | bool | true | no |
| `enable_scp_region_restriction` | Enable SCP to restrict regions | bool | true | no |
| `enable_scp_root_restriction` | Enable SCP to restrict root usage | bool | true | no |
| `allowed_regions` | List of allowed AWS regions | list(string) | ["us-east-2", "us-west-2"] | no |
| `ou_names` | Names of OUs to create | list(string) | ["Security", "Infrastructure", "Workloads", "Sandbox"] | no |
| `tags` | Common tags to apply to all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| `organization_id` | AWS Organization ID |
| `root_account_id` | Root account ID |
| `organizational_units` | Map of OU IDs by name |
| `accounts_created` | Map of created account IDs by name |
| `scps_attached` | List of SCP names attached |

## Example

### Full Organization Setup

```hcl
module "organization" {
  source = "./modules/organization"

  organization_enabled = true
  organization_name    = "AcmeCorp"
  
  aws_accounts = {
    log_archive = {
      name  = "Log Archive"
      email = "logs+master@acmecorp.com"
    }
    security_tooling = {
      name  = "Security"
      email = "security+master@acmecorp.com"
    }
    network = {
      name  = "Network Hub"
      email = "network+master@acmecorp.com"
    }
    shared_services = {
      name  = "Shared Services"
      email = "shared+master@acmecorp.com"
    }
    dev = {
      name  = "Development"
      email = "dev+master@acmecorp.com"
    }
    test = {
      name  = "Testing"
      email = "test+master@acmecorp.com"
    }
    prod = {
      name  = "Production"
      email = "prod+master@acmecorp.com"
    }
  }
  
  allowed_regions = ["us-east-2", "us-west-2"]
  
  tags = {
    Environment  = "prod"
    Application  = "landing-zone"
    Owner        = "devops-team"
    CostCenter   = "engineering"
  }
}

# Output account IDs for use in other modules
output "dev_account_id" {
  value = module.organization.accounts_created["dev"].id
}
```

## Dependencies

This module should be applied first as other modules depend on the accounts it creates.

- Standalone module (no module dependencies)
- Requires AWS Organizations service enabled

## Resources Created

- `aws_organizations_organization` — AWS Organization
- `aws_organizations_organizational_unit` — OUs (Security, Infrastructure, Workloads, Sandbox)
- `aws_organizations_account` — AWS Accounts (one per account key)
- `aws_organizations_policy` — Service Control Policies (4 policies)
- `aws_organizations_policy_attachment` — SCP attachments to OUs

## Notes

- **Account Creation Time**: AWS takes 10-15 minutes to provision new accounts
- **Email Requirements**: Each account needs a unique email address
- **SCPs are Deny Policies**: They restrict what's allowed (whitelist approach)
- **Root OU**: SCPs attached to root affect all accounts
- **Enable Early**: Enable SCPs immediately after organization creation to prevent misconfiguration

## Service Control Policies

### SCP: Prevent CloudTrail Disabling
Prevents users from disabling, stopping, or deleting CloudTrail in any account.

### SCP: Block Public S3 Access
Prevents users from making S3 buckets public or granting public access to objects.

### SCP: Restrict Regions
Restricts AWS API calls to only allowed regions (default: us-east-2, us-west-2).

### SCP: Prevent Root Usage
Prevents root account from performing any actions, enforcing IAM user access.

## Troubleshooting

**Issue: Account creation fails**
```bash
# Check AWS Organizations console for pending invitations
aws organizations list-accounts --query 'Accounts[?Status==`INVITED`]'

# Check email for AWS account invitation
```

**Issue: SCP not attaching**
- Ensure SCPs are enabled on the organization: `aws organizations list-policies --filter SERVICE_CONTROL_POLICY`
- Verify OU exists before attaching SCP
- Check IAM permissions: `organizations:AttachPolicy`

**Issue: Root account ID not found**
```bash
# Get root account ID
aws organizations list-accounts --query 'Accounts[0].Id'
```

## Terraform State Considerations

This module manages stateful AWS resources. Ensure:
- Remote state backend is configured (S3 + DynamoDB)
- State locking is enabled
- State is encrypted
- Team members have limited access to state files

---

**Last Updated**: 2026-05-20  
**Terraform**: 1.6.0+  
**AWS Provider**: Latest stable
