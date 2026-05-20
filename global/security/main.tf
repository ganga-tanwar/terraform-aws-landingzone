module "logging" {
  source = "../../modules/logging"

  name_prefix     = "enterprise-lz"
  organization_id = var.organization_id
  tags            = var.tags
}

module "security_baseline" {
  source = "../../modules/security"

  name_prefix           = "enterprise-lz"
  log_bucket_name       = module.logging.log_bucket_name
  log_kms_key_arn       = module.logging.log_kms_key_arn
  is_organization_trail = true
  tags                  = var.tags
}

module "iam_baseline" {
  source = "../../modules/iam_baseline"

  trusted_principal_arns = var.trusted_principal_arns
  tags                   = var.tags
}
