module "vpc" {
  source = "../../modules/network_vpc"

  name                = "prod"
  environment         = "Prod"
  vpc_cidr            = "10.30.0.0/16"
  azs                 = ["us-east-2a", "us-east-2b", "us-east-2c"]
  public_subnet_cidrs = ["10.30.0.0/24", "10.30.1.0/24", "10.30.2.0/24"]
  app_subnet_cidrs    = ["10.30.10.0/24", "10.30.11.0/24", "10.30.12.0/24"]
  db_subnet_cidrs     = ["10.30.20.0/24", "10.30.21.0/24", "10.30.22.0/24"]
  transit_gateway_id  = var.transit_gateway_id
  flow_log_bucket_arn = var.log_bucket_arn
  tags                = merge(var.tags, { Environment = "Prod" })
}

module "endpoints" {
  source = "../../modules/endpoints"

  name               = "prod"
  environment        = "Prod"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.app_subnet_ids
  route_table_ids    = module.vpc.private_route_table_ids
  security_group_ids = [module.vpc.workload_security_group_id]
  tags               = merge(var.tags, { Environment = "Prod" })
}

module "backup" {
  source      = "../../modules/backup"
  name_prefix = "prod"
  tags        = merge(var.tags, { Environment = "Prod" })
}

module "mgn_readiness" {
  source = "../../modules/mgn_readiness"

  name_prefix            = "prod"
  staging_area_subnet_id = module.vpc.app_subnet_ids[0]
  tags                   = merge(var.tags, { Environment = "Prod" })
}

module "windows_sql" {
  source = "../../modules/compute"

  name_prefix              = "prod-migration"
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.db_subnet_ids
  security_group_ids       = [module.vpc.workload_security_group_id]
  ami_id                   = var.windows_sql_ami_id
  allowed_management_cidrs = var.allowed_management_cidrs
  instances = {
    win-app-01 = { instance_type = "m6i.xlarge", subnet_index = 0, workload_type = "windows", data_volume_size = 200 }
    win-app-02 = { instance_type = "m6i.xlarge", subnet_index = 1, workload_type = "windows", data_volume_size = 200 }
    win-app-03 = { instance_type = "m6i.xlarge", subnet_index = 2, workload_type = "windows", data_volume_size = 200 }
    sql-01     = { instance_type = "r6i.2xlarge", subnet_index = 0, workload_type = "sql", data_volume_size = 2048, data_volume_iops = 12000 }
    sql-02     = { instance_type = "r6i.2xlarge", subnet_index = 1, workload_type = "sql", data_volume_size = 2048, data_volume_iops = 12000 }
  }
  tags = merge(var.tags, { Environment = "Prod", BackupPolicy = "Critical" })
}
