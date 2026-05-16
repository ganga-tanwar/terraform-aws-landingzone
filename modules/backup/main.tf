resource "aws_backup_vault" "this" {
  name        = "${var.name_prefix}-vault"
  kms_key_arn = var.backup_vault_kms_key_arn
  tags        = var.tags
}

resource "aws_iam_role" "backup" {
  name               = "${var.name_prefix}-backup-role"
  assume_role_policy = data.aws_iam_policy_document.backup_assume.json
  tags               = var.tags
}

data "aws_iam_policy_document" "backup_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_backup_plan" "this" {
  name = "${var.name_prefix}-plan"

  rule {
    rule_name         = "daily"
    target_vault_name = aws_backup_vault.this.name
    schedule          = "cron(0 5 ? * * *)"

    lifecycle {
      cold_storage_after = 30
      delete_after       = 365
    }

    dynamic "copy_action" {
      for_each = var.dr_vault_arn == null ? [] : [var.dr_vault_arn]
      content {
        destination_vault_arn = copy_action.value

        lifecycle {
          cold_storage_after = 30
          delete_after       = 365
        }
      }
    }
  }

  tags = var.tags
}

resource "aws_backup_selection" "tagged" {
  iam_role_arn = aws_iam_role.backup.arn
  name         = "${var.name_prefix}-tag-selection"
  plan_id      = aws_backup_plan.this.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "BackupPolicy"
    value = var.backup_selection_tag_value
  }
}
