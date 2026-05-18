data "aws_caller_identity" "current" {}

resource "aws_kms_key" "dr" {
  description             = "DR readiness KMS key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_kms_alias" "dr" {
  name          = "alias/${var.name_prefix}-dr"
  target_key_id = aws_kms_key.dr.key_id
}

resource "aws_backup_vault" "dr" {
  name        = "${var.name_prefix}-dr-vault"
  kms_key_arn = aws_kms_key.dr.arn
  tags        = var.tags
}

resource "aws_s3_bucket" "replica" {
  bucket        = "${var.name_prefix}-${data.aws_caller_identity.current.account_id}-dr-replica"
  force_destroy = false
  tags          = var.tags
}

resource "aws_s3_bucket_versioning" "replica" {
  bucket = aws_s3_bucket.replica.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_route53_record" "primary" {
  count = var.route53_zone_id == null || var.failover_record_name == null || var.primary_dns_name == null ? 0 : 1

  zone_id = var.route53_zone_id
  name    = var.failover_record_name
  type    = "CNAME"
  ttl     = 60
  records = [var.primary_dns_name]

  set_identifier = "primary"

  failover_routing_policy {
    type = "PRIMARY"
  }
}

resource "aws_route53_record" "secondary" {
  count = var.route53_zone_id == null || var.failover_record_name == null || var.secondary_dns_name == null ? 0 : 1

  zone_id = var.route53_zone_id
  name    = var.failover_record_name
  type    = "CNAME"
  ttl     = 60
  records = [var.secondary_dns_name]

  set_identifier = "secondary"

  failover_routing_policy {
    type = "SECONDARY"
  }
}
