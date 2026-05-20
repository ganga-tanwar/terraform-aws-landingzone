data "aws_organizations_organization" "existing" {}

resource "aws_organizations_organization" "this" {
  count = length(data.aws_organizations_organization.existing.roots) == 0 ? 1 : 0

  feature_set          = var.organization_feature_set
  enabled_policy_types = var.enabled_policy_types
}

locals {
  root_id = try(data.aws_organizations_organization.existing.roots[0].id, aws_organizations_organization.this[0].roots[0].id)
}


# resource "aws_organizations_organization" "this" {
#   aws_service_access_principals = [
#     "cloudtrail.amazonaws.com",
#     "config.amazonaws.com",
#     "sso.amazonaws.com",
#     "guardduty.amazonaws.com",
#     "securityhub.amazonaws.com",
#     "access-analyzer.amazonaws.com",
#     "backup.amazonaws.com",
#     "inspector2.amazonaws.com",
#     "macie.amazonaws.com",
#     "account.amazonaws.com",
#     "ram.amazonaws.com",
#   ]

#   enabled_policy_types = [
#     "SERVICE_CONTROL_POLICY",
#     "TAG_POLICY",
#   ]

#   feature_set = "ALL"
# }

# locals {
#   root_id = aws_organizations_organization.this.roots[0].id
# }

resource "aws_organizations_organizational_unit" "this" {
  for_each  = var.organizational_units
  name      = each.value
  parent_id = local.root_id
  tags      = var.tags
}


# resource "aws_organizations_account" "this" {
#   for_each = var.accounts

#   name      = each.key
#   email     = each.value.email
#   parent_id = aws_organizations_organizational_unit.this[each.value.ou].id
#   role_name = each.value.role_name
#   tags      = merge(var.tags, each.value.tags)

#   lifecycle {
#     prevent_destroy = true
#   }
# }

resource "aws_organizations_policy" "scp" {
  for_each = var.scp_policy_documents

  name        = each.key
  description = "Landing zone SCP: ${each.key}"
  type        = "SERVICE_CONTROL_POLICY"
  content     = each.value
  tags        = var.tags
}

locals {
  scp_attachment_pairs = flatten([
    for policy_name, ou_names in var.scp_attachments : [
      for ou_name in ou_names : {
        key         = "${policy_name}:${ou_name}"
        policy_name = policy_name
        ou_name     = ou_name
      }
    ]
  ])
}

resource "aws_organizations_policy_attachment" "scp" {
  for_each = { for attachment in local.scp_attachment_pairs : attachment.key => attachment }

  policy_id = aws_organizations_policy.scp[each.value.policy_name].id
  target_id = aws_organizations_organizational_unit.this[each.value.ou_name].id
}
