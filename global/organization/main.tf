module "organization" {
  source = "../../modules/organization"

  accounts = {
    "Log Archive" = {
      email = "aws-log-archive@${var.account_email_domain}"
      ou    = "Security"
    }
    "Security Tooling" = {
      email = "aws-security-tooling@${var.account_email_domain}"
      ou    = "Security"
    }
    "Network" = {
      email = "aws-network@${var.account_email_domain}"
      ou    = "Infrastructure"
    }
    "Shared Services" = {
      email = "aws-shared-services@${var.account_email_domain}"
      ou    = "Infrastructure"
    }
    "Dev" = {
      email = "aws-dev@${var.account_email_domain}"
      ou    = "Workloads"
    }
    "Test" = {
      email = "aws-test@${var.account_email_domain}"
      ou    = "Workloads"
    }
    "Prod" = {
      email = "aws-prod@${var.account_email_domain}"
      ou    = "Workloads"
    }
  }

  scp_policy_documents = {
    prevent_disable_cloudtrail = file("${path.root}/../../policies/scp-prevent-disable-cloudtrail.json")
    block_public_s3            = file("${path.root}/../../policies/scp-block-public-s3.json")
    restrict_regions           = file("${path.root}/../../policies/scp-restrict-regions.json")
    restrict_root_usage        = file("${path.root}/../../policies/scp-restrict-root-usage.json")
  }

  scp_attachments = {
    prevent_disable_cloudtrail = ["Security", "Infrastructure", "Workloads", "Sandbox"]
    block_public_s3            = ["Security", "Infrastructure", "Workloads", "Sandbox"]
    restrict_regions           = ["Security", "Infrastructure", "Workloads", "Sandbox"]
    restrict_root_usage        = ["Security", "Infrastructure", "Workloads", "Sandbox"]
  }

  tags = var.tags
}
