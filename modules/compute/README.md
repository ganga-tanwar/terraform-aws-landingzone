# Compute Module

Provisions EC2 infrastructure for Windows and SQL Server workloads with encryption, Systems Manager integration, and CloudWatch monitoring.

## Overview

This module creates compute infrastructure:
- EC2 instances (Windows/Linux)
- EBS volumes with encryption (io2 for SQL, gp3 for OS)
- Security groups
- Systems Manager agent integration
- CloudWatch monitoring

## Features

- ✅ Multi-AZ EC2 placement
- ✅ EBS encryption with KMS
- ✅ Windows/SQL Server optimization (io2 volumes)
- ✅ Systems Manager integration
- ✅ CloudWatch detailed monitoring
- ✅ Auto-recovery capability
- ✅ Tag-based resource grouping

## Usage

```hcl
module "compute" {
  source = "./modules/compute"

  # Instance Configuration
  instance_type      = "m5.xlarge"
  instance_count     = 2
  
  # Windows/SQL Configuration
  ami_owner          = "amazon"
  os_type            = "windows"  # or "linux"
  
  # Networking
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.app_subnet_ids
  security_group_ids = [aws_security_group.app.id]
  
  # Storage
  enable_ebs_encryption = true
  root_volume_size      = 100
  root_volume_type      = "gp3"  # OS
  
  # Monitoring
  enable_detailed_monitoring = true
  enable_ssm_agent          = true
  
  tags = {
    Environment   = "prod"
    BackupPolicy  = "daily"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `instance_type` | EC2 instance type | string | "t3.medium" | no |
| `instance_count` | Number of instances | number | 1 | no |
| `ami_owner` | AMI owner (amazon, microsoft) | string | "amazon" | no |
| `os_type` | OS type (windows, linux) | string | "windows" | no |
| `vpc_id` | VPC ID | string | n/a | yes |
| `subnet_ids` | Subnet IDs | list(string) | n/a | yes |
| `security_group_ids` | Security group IDs | list(string) | [] | no |
| `enable_ebs_encryption` | Enable EBS encryption | bool | true | no |
| `root_volume_size` | Root volume size in GB | number | 100 | no |
| `root_volume_type` | Root volume type (gp3, io2) | string | "gp3" | no |
| `enable_detailed_monitoring` | Enable CloudWatch monitoring | bool | true | no |
| `enable_ssm_agent` | Enable Systems Manager agent | bool | true | no |
| `tags` | Common tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| `instance_ids` | List of instance IDs |
| `instance_private_ips` | List of private IP addresses |
| `security_group_id` | Security group ID |

## Windows/SQL Server Optimization

```hcl
# SQL Server workload (high IOPS)
module "sql_server" {
  source = "./modules/compute"

  instance_type = "r5.2xlarge"  # Memory optimized
  instance_count = 2
  os_type = "windows"
  
  # SQL requires high IOPS
  root_volume_type = "io2"
  root_volume_size = 500
  root_iops = 10000
  
  tags = {
    Workload = "sql-server"
    BackupPolicy = "daily"
  }
}

# Web server workload (standard)
module "web_server" {
  source = "./modules/compute"

  instance_type = "t3.large"
  instance_count = 3
  os_type = "windows"
  
  # Web servers can use general purpose
  root_volume_type = "gp3"
  root_volume_size = 100
  
  tags = {
    Workload = "web-app"
  }
}
```

## Systems Manager Integration

Enables AWS Systems Manager for:
- Patch management
- Run Command
- Session Manager (SSH-like access without SSH)
- Inventory tracking

```bash
# Connect to instance without SSH
aws ssm start-session --target i-0123456789abcdef0

# Run command on instance
aws ssm send-command \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["echo hello"]' \
  --instance-ids i-0123456789abcdef0
```

## EBS Volume Types

| Type | Use Case | Cost | IOPS |
|------|----------|------|------|
| **gp3** | General purpose (web, app) | Low | 3,000-16,000 |
| **io2** | Database (SQL Server, Oracle) | High | 64,000+ |
| **st1** | Big data, logs | Medium | 500 |

## CloudWatch Monitoring

Detailed monitoring includes:
- CPU utilization
- Disk read/write
- Network in/out
- Status checks
- Custom metrics

---

**Last Updated**: 2026-05-20
