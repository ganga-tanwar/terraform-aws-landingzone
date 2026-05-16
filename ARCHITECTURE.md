# Landing Zone Architecture

## Accounts and OUs

- Security OU: Log Archive, Security Tooling
- Infrastructure OU: Network, Shared Services
- Workloads OU: Dev, Test, Prod
- Sandbox OU: future self-service experimentation accounts

## Network

Each environment receives an isolated VPC with public, private application, and private database subnets across three Availability Zones. VPCs attach to a centrally managed Transit Gateway in the Network account. Shared Services hosts DNS forwarding, future Microsoft AD integration, Direct Connect readiness, and VPN readiness.

## Security

Organization-level CloudTrail, AWS Config, GuardDuty, Security Hub, IAM Access Analyzer, Inspector, Macie, VPC Flow Logs, encrypted log buckets, and AWS Backup create the baseline. SCPs prevent common destructive governance bypasses.

## Migration

The workload module provisions five private Windows/SQL EC2 instances with SSM, CloudWatch agent permissions, encrypted gp3 OS volumes, and io2 SQL data volumes. AWS Application Migration Service should be configured outside or alongside this repository for replication waves and cutover testing.

## Disaster Recovery

`dr_readiness` prepares secondary-region backup vaults, KMS, replica buckets, and Route53 failover records. Workloads are not deployed in `us-west-2` until the business activates a warm standby or pilot-light pattern.
