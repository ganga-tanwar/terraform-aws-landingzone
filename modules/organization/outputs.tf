output "ou_ids" {
  description = "Organizational unit IDs by name."
  value       = { for name, ou in aws_organizations_organizational_unit.this : name => ou.id }
}

# output "account_ids" {
#   description = "Account IDs by account name."
#   value       = { for name, account in aws_organizations_account.this : name => account.id }
# }

output "root_id" {
  description = "Organization root ID."
  value       = local.root_id
}
