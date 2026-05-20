# Security Module

Provisions comprehensive AWS security and compliance services including CloudTrail, AWS Config, GuardDuty, Security Hub, IAM Access Analyzer, Amazon Inspector, and AWS Macie.

## Overview

This module enables and configures enterprise security services:
- **CloudTrail** — API call logging and audit trail
- **AWS Config** — Configuration tracking and compliance
- **GuardDuty** — Intelligent threat detection
- **Security Hub** — Centralized security findings
- **IAM Access Analyzer** — Permission analysis and unused access detection
- **Amazon Inspector** — Automated vulnerability scanning
- **AWS Macie** — Data discovery and sensitive data protection

## Features

- ✅ Organization-wide CloudTrail with multi-region logging
- ✅ CloudTrail log file integrity validation
- ✅ AWS Config recorder tracking all resource changes
- ✅ GuardDuty threat detection across accounts
- ✅ Security Hub aggregating findings from all services
- ✅ IAM Access Analyzer for permission analysis
- ✅ Amazon Inspector v2 for EC2, ECR, Lambda scanning
- ✅ Optional Macie for S3 data classification
- ✅ CloudWatch integration for alerts

## Prerequisites

- Terraform >= 1.6
- AWS Organizations enabled (for org-wide services)
- CloudTrail and Config S3 logging buckets
- KMS keys for encryption (optional but recommended)
- IAM permissions for security service enablement

## Usage

```hcl
module "security" {
  source = "./modules/security"

  # CloudTrail Configuration
  enable_cloudtrail                = true
  cloudtrail_name                  = "org-trail"
  cloudtrail_s3_bucket             = "org-cloudtrail-logs"
  cloudtrail_kms_key_id            = aws_kms_key.cloudtrail.arn
  include_global_service_events    = true
  is_multi_region_trail            = true
  enable_log_file_validation       = true

  # AWS Config Configuration
  enable_config                    = true
  config_bucket_name               = "org-config-bucket"
  config_recorder_name             = "org-config-recorder"
  
  # GuardDuty Configuration
  enable_guardduty                 = true
  guardduty_detector_name          = "org-detector"
  
  # Security Hub Configuration
  enable_security_hub              = true
  security_hub_standards = [
    "arn:aws:securityhub:${data.aws_region.current.name}::standards/aws-foundational-security-best-practices/v/1.0.0",
    "arn:aws:securityhub:${data.aws_region.current.name}::standards/cis-aws-foundations-benchmark/v/1.2.0"
  ]
  
  # IAM Access Analyzer
  enable_access_analyzer           = true
  
  # Amazon Inspector
  enable_inspector                 = true
  inspector_scan_ec2               = true
  inspector_scan_ecr               = true
  inspector_scan_lambda            = true
  
  # Macie (Optional - for data discovery)
  enable_macie                     = false  # Set to true if needed
  
  tags = {
    Environment = "prod"
    Application = "landing-zone"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `enable_cloudtrail` | Enable CloudTrail | bool | true | no |
| `cloudtrail_name` | Name of CloudTrail | string | "org-trail" | no |
| `cloudtrail_s3_bucket` | S3 bucket for CloudTrail logs | string | n/a | yes |
| `cloudtrail_kms_key_id` | KMS key ID for encryption | string | "" | no |
| `is_multi_region_trail` | Multi-region trail | bool | true | no |
| `enable_log_file_validation` | CloudTrail log file validation | bool | true | no |
| `enable_config` | Enable AWS Config | bool | true | no |
| `config_bucket_name` | S3 bucket for Config | string | n/a | yes |
| `enable_guardduty` | Enable GuardDuty | bool | true | no |
| `enable_security_hub` | Enable Security Hub | bool | true | no |
| `security_hub_standards` | List of Security Hub standards to enable | list(string) | See defaults | no |
| `enable_access_analyzer` | Enable IAM Access Analyzer | bool | true | no |
| `enable_inspector` | Enable Amazon Inspector | bool | true | no |
| `enable_macie` | Enable Amazon Macie | bool | false | no |
| `tags` | Common tags for all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| `cloudtrail_id` | CloudTrail ID |
| `cloudtrail_arn` | CloudTrail ARN |
| `config_recorder_id` | AWS Config recorder ID |
| `guardduty_detector_id` | GuardDuty detector ID |
| `security_hub_arn` | Security Hub ARN |
| `access_analyzer_arn` | IAM Access Analyzer ARN |
| `inspector_resource_group_arn` | Inspector resource group ARN |

## Service Coverage

### CloudTrail
Logs all API calls to AWS services:
- **Multi-region**: Enabled for all regions
- **Log file validation**: Ensures logs haven't been tampered with
- **Data events**: Can be enabled for S3 and Lambda (not default, cost impact)
- **Retention**: Logs sent to S3 bucket with lifecycle policy

```
CloudTrail → S3 Bucket → Glacier (after 90 days)
         ↓
    CloudWatch Logs
         ↓
    CloudWatch Alarms
```

### AWS Config
Tracks configuration changes for all AWS resources:
- **Recorder**: Continuously records resource changes
- **Rules**: Evaluate resource compliance against policies
- **Remediations**: Auto-remediate non-compliant resources (optional)

```
Resource Change → Config Recorder → Config Rules → SNS Notification
                                           ↓
                                    Remediation (optional)
```

### GuardDuty
Intelligent threat detection:
- **Detects**: Unauthorized API calls, malware, reconnaissance
- **Uses**: ML, threat intelligence, anomaly detection
- **Output**: Findings to CloudWatch Events and SNS

### Security Hub
Central findings aggregator:
- **Imports**: GuardDuty, Inspector, Macie, Config, IAM Access Analyzer
- **Standards**: AWS Foundational Security Best Practices, CIS
- **Scoring**: Severity ratings for prioritization
- **Workflows**: Suppress, investigate, or remediate findings

### Inspector
Vulnerability scanning:
- **EC2**: OS vulnerabilities, network exposure
- **ECR**: Container image vulnerabilities
- **Lambda**: Lambda function dependencies
- **Findings**: Exported to Security Hub

### IAM Access Analyzer
Permission analysis:
- **Detects**: Unused permissions and roles
- **Finds**: External access to resources
- **Recommends**: Least-privilege policies

### Macie (Optional)
Data discovery and protection:
- **Discovers**: Sensitive data (PII, credentials) in S3
- **Classifies**: Data types and business value
- **Alerts**: On sensitive data exposure

## Example: Full Security Setup

```hcl
module "security" {
  source = "./modules/security"

  # CloudTrail to centralized logging bucket
  enable_cloudtrail        = true
  cloudtrail_s3_bucket     = aws_s3_bucket.org_logs.id
  cloudtrail_kms_key_id    = aws_kms_key.logs.arn
  is_multi_region_trail    = true
  enable_log_file_validation = true

  # AWS Config for compliance tracking
  enable_config            = true
  config_bucket_name       = aws_s3_bucket.config.id

  # GuardDuty for threat detection
  enable_guardduty         = true

  # Security Hub for findings aggregation
  enable_security_hub      = true
  security_hub_standards = [
    "arn:aws:securityhub:us-east-2::standards/aws-foundational-security-best-practices/v/1.0.0",
    "arn:aws:securityhub:us-east-2::standards/cis-aws-foundations-benchmark/v/1.2.0"
  ]

  # Inspector for vulnerability scanning
  enable_inspector         = true
  inspector_scan_ec2       = true
  inspector_scan_ecr       = true

  # IAM Access Analyzer
  enable_access_analyzer   = true

  # Macie (disabled by default, enable if S3 data needs scanning)
  enable_macie             = false

  tags = {
    Environment = "prod"
    Application = "landing-zone"
    Compliance  = "sox"
  }
}
```

## Security Service Workflow

```
┌──────────────────────────────────────────────────────────────┐
│                   AWS Account Activity                        │
└──────────────────────────────────────────────────────────────┘
   ↓          ↓           ↓          ↓         ↓
CloudTrail  Config    GuardDuty   Inspector  Macie
   ↓          ↓           ↓          ↓         ↓
   └─────────────────────────────────────────────┘
                      ↓
            Security Hub (Aggregates)
                      ↓
              CloudWatch Events
                      ↓
          SNS / Lambda / SIEM
```

## Dependencies

- Requires S3 buckets for CloudTrail and Config
- Requires KMS keys for encryption (optional but recommended)
- Works best when applied organization-wide
- Standalone module (no other module dependencies)

## Resources Created

- `aws_cloudtrail` — CloudTrail organization trail
- `aws_config_configuration_recorder` — Config recorder
- `aws_guardduty_detector` — GuardDuty detector
- `aws_securityhub_account` — Security Hub
- `aws_securityhub_standards_subscription` — Standards enablement
- `aws_analyzer` — IAM Access Analyzer
- `aws_inspector_resource_group` — Inspector resource group
- `aws_macie2_account` — Macie (if enabled)

## Notes

- **CloudTrail Data Events**: Not enabled by default (high cost). Enable if required by compliance.
- **Multi-Account**: When deployed from Organizations master account, applies to all accounts
- **Log Retention**: Configure S3 lifecycle policies for log retention and cost optimization
- **Encryption**: Use KMS keys for sensitive log encryption
- **Alerts**: Set up CloudWatch alarms for critical findings

## Troubleshooting

**Issue: CloudTrail not logging**
```bash
# Check trail status
aws cloudtrail get-trail-status --name org-trail

# Verify S3 bucket policy allows CloudTrail
aws s3api get-bucket-policy --bucket org-cloudtrail-logs
```

**Issue: Config not recording**
```bash
# Check recorder status
aws configservice describe-configuration-recorder-status

# Start recorder if stopped
aws configservice start-configuration-recorder --configuration-recorder-names org-config-recorder
```

**Issue: Security Hub not importing findings**
- Verify GuardDuty, Inspector, Macie are enabled first
- Check regional endpoints are enabled
- Wait 5-10 minutes for initial import

---

**Last Updated**: 2026-05-20  
**Terraform**: 1.6.0+  
**AWS Provider**: Latest stable
