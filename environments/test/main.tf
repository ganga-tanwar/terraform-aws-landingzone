module "vpc" {
  source = "../../modules/network_vpc"

  name                      = "test"
  environment               = "Test"
  vpc_cidr                  = "10.20.0.0/16"
  azs                       = ["us-east-2a", "us-east-2b", "us-east-2c"]
  public_subnet_cidrs       = ["10.20.0.0/24", "10.20.1.0/24", "10.20.2.0/24"]
  app_subnet_cidrs          = ["10.20.10.0/24", "10.20.11.0/24", "10.20.12.0/24"]
  db_subnet_cidrs           = ["10.20.20.0/24", "10.20.21.0/24", "10.20.22.0/24"]
  transit_gateway_id        = var.transit_gateway_id
  flow_log_bucket_arn       = var.log_bucket_arn
  enable_single_nat_gateway = false
  tags                      = merge(var.tags, { Environment = "Test" })
}

module "backup" {
  source      = "../../modules/backup"
  name_prefix = "test"
  tags        = merge(var.tags, { Environment = "Test" })
}

module "mgn_readiness" {
  source = "../../modules/mgn_readiness"

  name_prefix            = "test"
  staging_area_subnet_id = module.vpc.app_subnet_ids[0]
  tags                   = merge(var.tags, { Environment = "Test" })
}

module "windows_sql" {
  source = "../../modules/compute_windows_sql"

  name_prefix              = "test-migration"
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.db_subnet_ids
  security_group_ids       = [module.vpc.workload_security_group_id]
  ami_id                   = var.windows_sql_ami_id
  allowed_management_cidrs = var.allowed_management_cidrs
  instances = {
    win-app-01 = { instance_type = "m6i.large", subnet_index = 0, workload_type = "windows", data_volume_size = 100 }
    win-app-02 = { instance_type = "m6i.large", subnet_index = 1, workload_type = "windows", data_volume_size = 100 }
    win-app-03 = { instance_type = "m6i.large", subnet_index = 2, workload_type = "windows", data_volume_size = 100 }
    sql-01     = { instance_type = "r6i.xlarge", subnet_index = 0, workload_type = "sql", data_volume_size = 1024, data_volume_iops = 6000 }
    sql-02     = { instance_type = "r6i.xlarge", subnet_index = 1, workload_type = "sql", data_volume_size = 1024, data_volume_iops = 6000 }
  }
  tags = merge(var.tags, { Environment = "Test", BackupPolicy = "Daily" })
}
