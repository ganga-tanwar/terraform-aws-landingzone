module "transit_gateway" {
  source = "../../modules/transit_gateway"

  name                      = "enterprise-lz-tgw"
  share_with_principal_arns = var.ram_principal_arns
  tags                      = var.tags
}

module "shared_services_vpc" {
  source = "../../modules/network_vpc"

  name                = "shared-services"
  environment         = "Shared"
  vpc_cidr            = "10.0.0.0/16"
  azs                 = ["us-east-2a", "us-east-2b", "us-east-2c"]
  public_subnet_cidrs = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  app_subnet_cidrs    = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  db_subnet_cidrs     = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
  transit_gateway_id  = module.transit_gateway.transit_gateway_id
  flow_log_bucket_arn = var.log_bucket_arn
  tags                = merge(var.tags, { Environment = "Shared" })
}

module "shared_services_endpoints" {
  source = "../../modules/endpoints"

  name               = "shared-services"
  environment        = "Shared"
  vpc_id             = module.shared_services_vpc.vpc_id
  subnet_ids         = module.shared_services_vpc.app_subnet_ids
  route_table_ids    = module.shared_services_vpc.private_route_table_ids
  security_group_ids = [module.shared_services_vpc.workload_security_group_id]
  tags               = merge(var.tags, { Environment = "Shared" })
}

module "dns_resolver" {
  source = "../../modules/dns_resolver"

  name_prefix       = "enterprise-lz"
  vpc_id            = module.shared_services_vpc.vpc_id
  subnet_ids        = module.shared_services_vpc.app_subnet_ids
  on_premises_cidrs = var.on_premises_cidrs
  dns_forward_domains = {
    "corp.example.com" = ["10.100.0.10", "10.100.0.11"]
  }
  tags = var.tags
}

module "vpn" {
  source = "../../modules/vpn"

  name_prefix         = "enterprise-lz"
  transit_gateway_id  = module.transit_gateway.transit_gateway_id
  customer_gateway_ip = var.customer_gateway_ip
  tags                = var.tags
}
