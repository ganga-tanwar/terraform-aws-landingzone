# IAM Baseline Module

Provisions foundational IAM infrastructure including cross-account roles, Terraform deployment roles, break-glass emergency access, and permission boundaries for enterprise security.

## Overview

This module creates IAM security foundation with:
- Cross-account Terraform deployment role
- Break-glass emergency access role (AdministratorAccess)
- Permission boundaries for least-privilege enforcement
- MFA requirements for sensitive operations
- Service roles with permission boundaries
- Audit trail for role assumption

## Features

- ✅ Cross-account Terraform deployment role
- ✅ MFA requirement for break-glass access
- ✅ Permission boundaries for managed policies
- ✅ Session duration control (1-12 hours)
- ✅ Audit logging via CloudTrail
- ✅ Conditional MFA requirement
- ✅ IP-based access restrictions (optional)
- ✅ Session tags for cost allocation

## Prerequisites

- Terraform >= 1.6
- AWS Organizations enabled
- Knowledge of target accounts for cross-account roles
- CloudTrail configured for audit logging

## Usage

```hcl
module "iam_baseline" {
  source = "./modules/iam_baseline"

  # Terraform Deployment Role
  terraform_role_name        = "terraform-deployment"
  terraform_role_description = "Role for Terraform CI/CD pipeline"
  
  # MFA Configuration
  require_mfa_for_terraform = false  # False for CI/CD, True for manual
  
  # Break-Glass Emergency Role
  enable_break_glass_role    = true
  break_glass_role_name      = "breakglass-emergency-access"
  require_mfa_for_breakglass = true  # Always MFA for emergency access
  
  # Permission Boundaries
  enable_permission_boundary = true
  max_session_duration       = 3600  # 1 hour
  
  # Cross-Account Trust
  trusted_account_ids        = [
    "111111111111",  # Dev account
    "222222222222",  # Prod account
  ]
  
  # Service Roles (for workloads)
  enable_service_roles       = true
  
  tags = {
    Environment = "prod"
    Application = "landing-zone"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `terraform_role_name` | Name of Terraform deployment role | string | "terraform-deployment" | no |
| `terraform_role_description` | Description of Terraform role | string | "" | no |
| `require_mfa_for_terraform` | Require MFA for Terraform role | bool | false | no |
| `break_glass_role_name` | Name of break-glass role | string | "breakglass-emergency-access" | no |
| `require_mfa_for_breakglass` | Require MFA for break-glass role | bool | true | no |
| `enable_permission_boundary` | Enable permission boundaries | bool | true | no |
| `trusted_account_ids` | AWS account IDs to trust for cross-account | list(string) | [] | no |
| `enable_service_roles` | Enable service-specific roles | bool | true | no |
| `max_session_duration` | Max session duration in seconds | number | 3600 | no |
| `tags` | Common tags for all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| `terraform_role_arn` | ARN of Terraform deployment role |
| `terraform_role_name` | Name of Terraform deployment role |
| `break_glass_role_arn` | ARN of break-glass role |
| `break_glass_role_name` | Name of break-glass role |
| `permission_boundary_arn` | ARN of permission boundary policy |

## IAM Roles

### 1. Terraform Deployment Role

Used by CI/CD pipeline and Terraform to manage AWS infrastructure.

**Trust Relationship:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "terraform-deployment"
        }
      }
    }
  ]
}
```

**Permissions:**
- Broad AWS permissions (can be restricted further)
- No root account permissions
- Audit logged via CloudTrail

**Usage in CI/CD:**
```bash
# GitHub Actions
- name: Assume Terraform Role
  uses: aws-actions/configure-aws-credentials@v2
  with:
    role-to-assume: arn:aws:iam::123456789012:role/terraform-deployment
    aws-region: us-east-2
```

### 2. Break-Glass Emergency Access Role

For emergency access when normal processes fail.

**Features:**
- AdministratorAccess permission (unrestricted)
- MFA requirement (enforced)
- 1-hour session duration (limited)
- Heavily audited via CloudTrail
- Used only for emergencies

**Usage:**
```bash
# Assume break-glass role with MFA
aws sts assume-role \
  --role-arn arn:aws:iam::123456789012:role/breakglass-emergency-access \
  --role-session-name emergency-access \
  --serial-number arn:aws:iam::123456789012:mfa/user-name \
  --token-code 123456
```

## Permission Boundary Policy

Permission boundaries enforce maximum permissions across all IAM entities:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    },
    {
      "Effect": "Deny",
      "Action": [
        "iam:DeleteUser",
        "iam:DeleteRole",
        "iam:PutUserPolicy",
        "iam:AttachRolePolicy",
        "organizations:*"
      ],
      "Resource": "*"
    }
  ]
}
```

## Cross-Account Role Assumption

For multi-account deployments:

```hcl
# In Network Account (central)
module "iam_baseline" {
  source = "./modules/iam_baseline"

  terraform_role_name = "terraform-deployment"
  
  # Trust Dev and Prod accounts
  trusted_account_ids = [
    var.dev_account_id,
    var.prod_account_id,
  ]
}

# In Dev Account (workload)
resource "aws_iam_role" "dev_terraform" {
  name = "dev-terraform-runner"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.network_account_id}:role/terraform-deployment"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
```

## Example: Full Setup with Multiple Accounts

```hcl
# In Security Account (central IAM management)
module "iam_baseline" {
  source = "./modules/iam_baseline"

  # Terraform CI/CD role
  terraform_role_name        = "terraform-deployment"
  terraform_role_description = "For GitHub Actions CI/CD"
  require_mfa_for_terraform = false  # CI/CD doesn't have MFA
  
  # Emergency access
  enable_break_glass_role    = true
  break_glass_role_name      = "breakglass"
  require_mfa_for_breakglass = true
  
  # Permission boundaries
  enable_permission_boundary = true
  max_session_duration       = 3600  # 1 hour
  
  # Trust workload accounts
  trusted_account_ids = [
    var.dev_account_id,
    var.test_account_id,
    var.prod_account_id,
  ]
  
  tags = {
    Environment = "prod"
    Application = "iam-baseline"
  }
}

output "terraform_role_arn" {
  value = module.iam_baseline.terraform_role_arn
}
```

## Service Roles

For EC2, Lambda, and other services:

```hcl
# EC2 service role
resource "aws_iam_role" "ec2_service" {
  name = "ec2-service-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  
  # Apply permission boundary
  permissions_boundary = module.iam_baseline.permission_boundary_arn
}
```

## Session Tags for Cost Allocation

Tag sessions for cost tracking:

```hcl
resource "aws_iam_role" "terraform" {
  name = "terraform-deployment"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:RoleSessionName" = "terraform-*"
          }
        }
      }
    ]
  })
  
  tags = {
    Role    = "terraform"
    Session = "ci-cd"
  }
}
```

## Dependencies

- Standalone module (no other module dependencies)
- CloudTrail recommended for audit logging
- MFA devices configured (if MFA required)

## Resources Created

- `aws_iam_role` — Terraform deployment role
- `aws_iam_role` — Break-glass role
- `aws_iam_role_policy` — Inline policies
- `aws_iam_policy` — Permission boundary policy
- `aws_iam_policy_version` — Policy versions

## Notes

- **Terraform Role**: Broad permissions OK for infrastructure automation
- **Break-Glass**: Emergency-only, heavily monitored
- **MFA**: Required for manual access, not needed for CI/CD
- **Permission Boundary**: Prevents privilege escalation
- **Audit**: All role assumptions logged in CloudTrail

## Troubleshooting

**Issue: Assume role fails with "user is not authorized"**
```bash
# Check IAM user/role permissions
aws iam get-user

# Check role trust policy
aws iam get-role --role-name terraform-deployment
```

**Issue: MFA token rejected**
- Ensure correct MFA device serial number
- Check token is current (tokens expire after 30 seconds)
- Verify MFA device is synchronized

**Issue: Session duration too short**
- Increase `max_session_duration` parameter
- Default 1 hour, can be up to 12 hours

---

**Last Updated**: 2026-05-20  
**Terraform**: 1.6.0+  
**AWS Provider**: Latest stable
