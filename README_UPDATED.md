# AWS Landing Zone - Terraform Implementation

**Enterprise-grade, production-ready AWS Landing Zone infrastructure-as-code using Terraform.**

Provision a secure, scalable, multi-account AWS Organization with hub-and-spoke networking, comprehensive security baselines, and automated CI/CD pipelines designed for mission-critical Windows and SQL Server migrations.

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [Architecture](#architecture)
4. [Directory Structure](#directory-structure)
5. [Modules](#modules)
6. [Prerequisites](#prerequisites)
7. [Deployment Guide](#deployment-guide)
8. [Configuration](#configuration)
9. [Cost Considerations](#cost-considerations)
10. [Support & Troubleshooting](#support--troubleshooting)
11. [Contributing](#contributing)

---

## 🎯 Overview

This repository contains a complete, production-grade Terraform implementation of an AWS Landing Zone designed for enterprise organizations. It provisions:

- **Multi-Account Architecture** — AWS Organizations with Security, Infrastructure, Workloads, and Sandbox OUs
- **Secure Networking** — Hub-and-spoke topology with Transit Gateway, 4 VPCs across 3 availability zones
- **Security & Governance** — CloudTrail, AWS Config, GuardDuty, Security Hub, centralized logging, and compliance monitoring
- **Hybrid Connectivity** — Site-to-Site VPN, Route53 DNS resolution for on-premises integration
- **Disaster Recovery** — Cross-region backup strategy, secondary region readiness
- **CI/CD Pipeline** — GitHub Actions with automated testing (terraform fmt, validate, tfsec, checkov)
- **Compute Readiness** — EC2 configuration for Windows and SQL Server migrations

**Perfect for**: Organizations migrating on-premises workloads to AWS with requirements for security, compliance, and operational excellence.

---

## 🚀 Quick Start

### Prerequisites
- **Terraform** >= 1.6.0 (see [versions.tf](versions.tf))
- **AWS Account** with administrative access
- **AWS CLI** v2 configured with credentials
- **Git** for version control
- **Python 3.8+** (for optional scripts)

### Basic Deployment (5 minutes)

```bash
# 1. Clone the repository
git clone https://github.com/your-org/terraform-aws-landingzone.git
cd terraform-aws-landingzone

# 2. Initialize Terraform (creates S3 backend and DynamoDB lock table)
cd global/bootstrap
terraform init
terraform apply

# 3. Deploy AWS Organizations
cd ../organization
terraform init -backend-config="bucket=YOUR_STATE_BUCKET" -backend-config="key=organization.tfstate"
terraform plan
terraform apply

# 4. Deploy core security and networking
cd ../security
terraform init
terraform apply

cd ../network
terraform init
terraform apply

# 5. Deploy environment-specific resources
cd ../../environments/prod
terraform init
terraform apply
```

> **For detailed step-by-step instructions**, see [Deployment Guide](#deployment-guide) below.

---

## 🏗️ Architecture

### Account Structure

```
AWS Organization (Root)
├── Security OU
│   ├── Log Archive Account (logs, backups, compliance data)
│   └── Security Tooling Account (GuardDuty, Security Hub, access analyzer)
├── Infrastructure OU
│   ├── Network Account (Transit Gateway, shared networking)
│   └── Shared Services Account (DNS, identity, bastion hosts)
├── Workloads OU
│   ├── Dev Account (development resources)
│   ├── Test Account (QA and testing)
│   └── Prod Account (production workloads)
└── Sandbox OU (experimental, isolated)
```

### Network Topology

**Hub-and-Spoke Design** using AWS Transit Gateway:

```
┌─────────────────────────────────────────────────────────────────────┐
│                      AWS Transit Gateway Hub                        │
│                    (us-east-2 primary region)                       │
└─────────────────────────────────────────────────────────────────────┘
        ↓             ↓               ↓              ↓
    ┌────────┐  ┌─────────┐  ┌──────────┐  ┌─────────────┐
    │ Shared │  │   Dev   │  │   Test   │  │    Prod     │
    │Services│  │   VPC   │  │   VPC    │  │    VPC      │
    │  VPC   │  │10.10.0 │  │10.20.0  │  │ 10.30.0    │
    │10.0.0 │  │  /16   │  │  /16    │  │  /16       │
    └────────┘  └─────────┘  └──────────┘  └─────────────┘
    3 AZs       1 AZ         1 AZ           3 AZs
    HA Setup    Cost Opt    Cost Opt       HA + DR Ready
```

### CIDR Allocation

| VPC | CIDR Block | Region | AZs | Purpose |
|-----|-----------|--------|-----|---------|
| Shared Services | 10.0.0.0/16 | us-east-2 | 3 | Centralized services (DNS, bastion, VPN) |
| Dev | 10.10.0.0/16 | us-east-2 | 1 | Development workloads |
| Test | 10.20.0.0/16 | us-east-2 | 1 | Testing and QA |
| Prod | 10.30.0.0/16 | us-east-2 | 3 | Production workloads (HA) |
| **DR Ready** | — | us-west-2 | TBD | Secondary region (future) |

### Security Layers

1. **Organization Level**: Service Control Policies (SCPs) prevent disabling CloudTrail, public S3, specific regions
2. **Network Level**: Security Groups, NACLs, VPC Flow Logs
3. **Data Level**: KMS encryption at rest, TLS in transit
4. **Monitoring Level**: CloudTrail (all API calls), VPC Flow Logs, AWS Config (resource compliance)
5. **Detection Level**: GuardDuty (threats), Security Hub (findings), IAM Access Analyzer (permissions)

---

## 📁 Directory Structure

```
terraform-aws-landingzone/
├── README.md                    # This file
├── ARCHITECTURE.md              # Detailed architecture documentation
├── versions.tf                  # Terraform and provider versions
├── .gitignore                   # Git ignore patterns
├── scripts/                     # Operational scripts
│   ├── bootstrap.sh             # First-time setup script
│   ├── deploy.sh                # Deployment automation
│   └── destroy.sh               # Cleanup script
├── global/                      # Organization-level resources (apply once)
│   ├── bootstrap/               # S3 backend, DynamoDB lock table
│   ├── organization/            # AWS Organizations, OUs, SCPs
│   ├── security/                # CloudTrail, Config, GuardDuty
│   └── network/                 # Transit Gateway, core networking
├── modules/                     # Reusable Terraform modules
│   ├── organization/            # AWS Organizations management
│   ├── iam_baseline/            # IAM roles, policies, permissions boundaries
│   ├── network_vpc/             # VPC, subnets, routing, NACLs
│   ├── transit_gateway/         # Transit Gateway hub
│   ├── nat_gateway/             # NAT Gateways for private subnets
│   ├── endpoints/               # VPC endpoints (S3, DynamoDB, interface endpoints)
│   ├── dns_resolver/            # Route53 Resolver for hybrid DNS
│   ├── vpn/                     # Site-to-Site VPN configuration
│   ├── security/                # Security services (CloudTrail, GuardDuty, etc.)
│   ├── logging/                 # Centralized S3 logging bucket
│   ├── backup/                  # AWS Backup vaults and policies
│   └── compute/                 # EC2 instances, security groups
├── environments/                # Environment-specific configurations
│   ├── dev/                     # Development environment
│   │   ├── main.tf
│   │   ├── terraform.tfvars
│   │   └── README.md
│   ├── test/                    # Test environment
│   ├── prod/                    # Production environment
│   └── variables.tf             # Shared environment variables
├── policies/                    # Policy documents
│   ├── scp-*.json               # Service Control Policies
│   ├── iam-*.json               # IAM policy documents
│   └── README.md                # Policy documentation
├── pipelines/                   # CI/CD pipeline definitions
│   ├── github-actions.yml       # GitHub Actions workflow
│   └── README.md                # Pipeline documentation
└── .github/                     # GitHub configuration (if used)
    └── workflows/               # GitHub Actions workflows
```

**Key points:**
- `global/` — Applied first, organization-level resources
- `modules/` — Reusable components called by `global/` and `environments/`
- `environments/` — Environment-specific values (dev, test, prod)
- `pipelines/` — CI/CD configuration for automated testing and deployment

---

## 🔧 Modules

All modules are designed to be production-grade, reusable, and independently testable. Each includes comprehensive variable documentation and examples.

### Core Modules

| Module | Purpose | Documentation |
|--------|---------|-----------------|
| **organization** | AWS Organizations, OUs, account creation, SCPs | [modules/organization/README.md](modules/organization/README.md) |
| **iam_baseline** | Cross-account IAM roles, trust relationships, break-glass emergency access | [modules/iam_baseline/README.md](modules/iam_baseline/README.md) |
| **network_vpc** | VPC, subnets (public/app/database), routing, NACLs | [modules/network_vpc/README.md](modules/network_vpc/README.md) |
| **transit_gateway** | Transit Gateway hub, resource sharing, DNS support | [modules/transit_gateway/README.md](modules/transit_gateway/README.md) |
| **nat_gateway** | NAT Gateways for private subnet outbound traffic | [modules/nat_gateway/README.md](modules/nat_gateway/README.md) |
| **endpoints** | VPC Endpoints (Gateway: S3/DynamoDB, Interface: API endpoints) | [modules/endpoints/README.md](modules/endpoints/README.md) |
| **dns_resolver** | Route53 Resolver for on-premises DNS forwarding | [modules/dns_resolver/README.md](modules/dns_resolver/README.md) |
| **vpn** | Site-to-Site VPN to Transit Gateway | [modules/vpn/README.md](modules/vpn/README.md) |
| **security** | CloudTrail, AWS Config, GuardDuty, Security Hub, Inspector, Macie, Access Analyzer | [modules/security/README.md](modules/security/README.md) |
| **logging** | Centralized S3 logging bucket, KMS encryption, lifecycle policies | [modules/logging/README.md](modules/logging/README.md) |
| **backup** | AWS Backup vaults, daily schedules, cross-region replication | [modules/backup/README.md](modules/backup/README.md) |
| **compute** | EC2 instances (Windows/SQL Server), security groups, Systems Manager, CloudWatch | [modules/compute/README.md](modules/compute/README.md) |

---

## 📋 Prerequisites

### 1. AWS Account Setup

- [ ] AWS organization created or existing account available
- [ ] AWS CLI v2 installed and configured
- [ ] IAM user/role with AdministratorAccess (for first deployment only)
- [ ] Understand AWS billing and cost constraints

### 2. Terraform Setup

- [ ] Terraform 1.6.0+ installed
  ```bash
  terraform version  # Should show v1.6.0 or higher
  ```
- [ ] AWS provider credentials configured
  ```bash
  aws sts get-caller-identity  # Should return your AWS account
  ```

### 3. Network Setup

- [ ] On-premises network CIDR ranges documented (for VPN configuration)
- [ ] Decision on primary region: **us-east-2** (current default)
- [ ] Understanding of hub-and-spoke topology
- [ ] VPN hardware/software requirements identified (if hybrid connectivity needed)

### 4. Compliance & Governance

- [ ] Tagging strategy documented (Environment, Application, Owner, CostCenter, Compliance, BackupPolicy)
- [ ] Data residency requirements understood
- [ ] Compliance frameworks identified (SOC 2, HIPAA, PCI DSS, etc.)
- [ ] Disaster recovery RTO/RPO targets set

### 5. Repository Setup

```bash
# Clone the repository
git clone https://github.com/your-org/terraform-aws-landingzone.git
cd terraform-aws-landingzone

# Create local Terraform variables file (do NOT commit to Git)
cp environments/prod/terraform.tfvars.example environments/prod/terraform.tfvars

# Edit with your values
vi environments/prod/terraform.tfvars
```

---

## 📖 Deployment Guide

### Phase 1: Bootstrap (Initialize Remote State)

```bash
cd global/bootstrap

# Initialize Terraform (local state for bootstrap)
terraform init

# Review what will be created (S3 bucket, DynamoDB table)
terraform plan

# Create remote state backend
terraform apply

# Note: Outputs will show state bucket name and DynamoDB table name
# You'll use these in Phase 2
```

**Resources created:**
- S3 bucket for Terraform state (with versioning and encryption)
- DynamoDB table for state locking
- KMS key for bucket encryption

### Phase 2: Organizations & IAM

```bash
cd ../organization

# Initialize with remote backend
terraform init \
  -backend-config="bucket=YOUR_STATE_BUCKET" \
  -backend-config="key=organization.tfstate" \
  -backend-config="dynamodb_table=YOUR_LOCK_TABLE" \
  -backend-config="region=us-east-2"

# Plan and apply
terraform plan -out=tfplan
terraform apply tfplan
```

**Resources created:**
- AWS Organization (if not exists)
- 4 Organizational Units (Security, Infrastructure, Workloads, Sandbox)
- 7 AWS Accounts
- 4 Service Control Policies

**⚠️ Note:** Account creation may take 10-15 minutes. Check AWS Console under Organizations.

### Phase 3: Security & Logging

```bash
cd ../security

terraform init -backend-config=...  # Same as Phase 2
terraform plan -out=tfplan
terraform apply tfplan
```

**Resources created:**
- CloudTrail (organization-wide, multi-region)
- AWS Config (configuration recorder)
- GuardDuty (threat detection)
- Security Hub (findings aggregation)
- IAM Access Analyzer
- CloudWatch Log Groups for centralized logging

### Phase 4: Networking

```bash
cd ../network

terraform init -backend-config=...
terraform plan -out=tfplan
terraform apply tfplan
```

**Resources created:**
- 4 VPCs (Shared Services, Dev, Test, Prod)
- 12 subnets per VPC (public, app, database × 3 AZs)
- Internet Gateways, NAT Gateways
- Route tables and routes
- Network ACLs
- VPC Flow Logs (to S3)
- Transit Gateway
- VPC Endpoints
- Route53 Resolver (hybrid DNS)

### Phase 5: Environments (Dev/Test/Prod)

```bash
# Deploy each environment separately
cd ../../environments/dev
terraform init -backend-config=...
terraform plan -out=tfplan
terraform apply tfplan

# Repeat for test and prod
cd ../test
terraform init -backend-config=...
terraform apply

cd ../prod
terraform init -backend-config=...
terraform apply
```

**Resources created per environment:**
- VPC-specific security groups
- EC2 instances (if compute module enabled)
- CloudWatch monitoring
- Backup policies

### Automated Deployment (Optional)

```bash
# Use deployment script for all phases
bash scripts/deploy.sh prod

# For development:
bash scripts/deploy.sh dev
```

---

## ⚙️ Configuration

### Customizing for Your Organization

#### 1. Environment Variables

Edit `environments/prod/terraform.tfvars`:

```hcl
# Organization settings
organization_name = "YourOrgName"
environment       = "prod"

# Network settings
vpc_cidr          = "10.30.0.0/16"
availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]

# Tagging
tags = {
  Environment  = "prod"
  Application  = "landing-zone"
  Owner        = "devops-team"
  CostCenter   = "engineering"
  Compliance   = "sox"
  BackupPolicy = "daily"
}
```

#### 2. Account Configuration

Edit `modules/organization/variables.tf`:

```hcl
# Add new AWS accounts as needed
accounts = {
  security_tooling = {
    name  = "Security Tooling"
    email = "aws-security@company.com"
  }
  # Add more accounts...
}
```

#### 3. Network Customization

Edit `global/network/terraform.tfvars`:

```hcl
# Enable/disable features
enable_vpc_flow_logs = true
enable_vpc_endpoints = true
enable_vpn          = false  # Set true for hybrid connectivity
enable_dns_resolver  = true

# VPN configuration
vpn_customer_gateway_ip = "203.0.113.1"  # Your on-premises VPN endpoint
```

#### 4. Security Services

Edit `global/security/terraform.tfvars`:

```hcl
# Enable/disable security services
cloudtrail_enabled    = true
config_enabled        = true
guardduty_enabled     = true
security_hub_enabled  = true
macie_enabled         = true  # Enables S3 data discovery
```

---

## 💰 Cost Considerations

### Estimated Monthly Costs

| Component | Estimated Cost | Notes |
|-----------|----------------|-------|
| AWS Organizations | FREE | No charge for Organizations itself |
| Transit Gateway | $0.05/hour + $0.02/GB | ~$36-100/month depending on traffic |
| CloudTrail | $2 + $0.10/million events | ~$10-50/month |
| AWS Config | $3 + $0.30/config item | ~$20-100/month |
| GuardDuty | $3-15 | Per account, per month |
| VPC Flow Logs | $0.50/million records | ~$10-50/month |
| S3 (Logs + State) | $0.023/GB | ~$5-20/month |
| NAT Gateway | $0.045/hour + $0.045/GB | ~$45-100/month |
| **TOTAL** | **~$150-500/month** | For full landing zone |

### Cost Optimization Tips

1. **Development Environment**: 
   - Use single NAT Gateway (not HA)
   - Single AZ instead of 3
   - Smaller EC2 instances
   - Cost: ~$30-50/month

2. **CloudTrail Data Events**:
   - Disabled by default (enable if compliance requires)
   - Can increase costs by 10x if enabled
   - Enable selectively for high-value data

3. **VPC Flow Logs**:
   - Consider sampling (1 in 10 packets) to reduce costs
   - Use S3 with lifecycle transitions to Glacier

4. **Reserve Capacity**:
   - Use AWS Savings Plans for predictable workloads
   - Can reduce EC2 costs by 30-50%

5. **Consolidate Accounts**:
   - Fewer OUs/accounts = lower overhead
   - Shared Services VPC for common resources

---

## 🆘 Support & Troubleshooting

### Common Issues

**Issue: State lock timeout**
```bash
# Check if lock exists
aws dynamodb get-item \
  --table-name terraform-locks \
  --key '{"LockID":{"S":"terraform-aws-landingzone.tfstate"}}'

# Force unlock (use with caution!)
terraform force-unlock <LOCK_ID>
```

**Issue: Permission denied errors**
```bash
# Verify AWS credentials
aws sts get-caller-identity

# Check IAM permissions
aws iam get-user
```

**Issue: VPC CIDR conflicts**
```bash
# Check existing VPCs
aws ec2 describe-vpcs --region us-east-2

# Update CIDR allocation in terraform.tfvars
```

**Issue: Account creation fails**
- Wait 10-15 minutes (AWS takes time to create accounts)
- Check AWS Organizations console for pending accounts
- Review CloudTrail for error messages

### Getting Help

1. **Documentation**: See [ARCHITECTURE.md](ARCHITECTURE.md) for deep dives
2. **Module README**: Each module has usage examples and troubleshooting
3. **AWS Support**: For AWS-specific issues, contact AWS Support
4. **Terraform**: For Terraform issues, check [Terraform docs](https://www.terraform.io/docs)

---

## 🤝 Contributing

### Making Changes

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Make changes and test locally: `terraform plan`
3. Commit: `git commit -am "Add feature"`
4. Push: `git push origin feature/your-feature`
5. Create pull request with description

### Testing

```bash
# Validate Terraform syntax
terraform validate

# Format code
terraform fmt -recursive

# Security scanning
tfsec

# Policy as code
checkov
```

### Submitting Issues

Use GitHub Issues with:
- **Title**: Clear, descriptive
- **Description**: Steps to reproduce, expected vs. actual
- **Environment**: Terraform version, AWS region, OS
- **Logs**: Terraform output or error messages

---

## 📝 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

---

## 📞 Additional Resources

- **AWS Well-Architected Framework**: https://aws.amazon.com/architecture/well-architected/
- **Terraform AWS Provider**: https://registry.terraform.io/providers/hashicorp/aws/latest
- **AWS Landing Zone Best Practices**: https://docs.aws.amazon.com/controltower/latest/userguide/what-is-control-tower.html
- **Security Best Practices**: https://docs.aws.amazon.com/security/

---

**Last Updated**: 2026-05-20  
**Terraform Version**: 1.6.0+  
**AWS Provider**: Latest stable
