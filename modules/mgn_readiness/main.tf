resource "aws_iam_service_linked_role" "mgn" {
  aws_service_name = "mgn.amazonaws.com"
  description      = "Service-linked role for AWS Application Migration Service"
}

# resource "aws_mgn_replication_configuration_template" "this" {
#   associate_default_security_group = false
#   bandwidth_throttling             = 0
#   create_public_ip                 = false
#   data_plane_routing               = "PRIVATE_IP"
#   default_large_staging_disk_type  = "GP3"
#   ebs_encryption                   = "DEFAULT"
#   replication_server_instance_type = var.replication_server_instance_type
#   staging_area_subnet_id           = var.staging_area_subnet_id
#   staging_area_tags                = merge(var.tags, { Name = "${var.name_prefix}-mgn-staging" })
#   use_dedicated_replication_server = false

#   depends_on = [aws_iam_service_linked_role.mgn]

#   tags = var.tags
# }

