data "aws_iam_policy_document" "assume_trusted" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.trusted_principal_arns
    }

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
}

resource "aws_iam_role" "terraform" {
  name                 = var.terraform_role_name
  assume_role_policy   = data.aws_iam_policy_document.assume_trusted.json
  permissions_boundary = var.permissions_boundary_arn
  tags                 = var.tags
}

resource "aws_iam_policy" "terraform_deploy" {
  name        = "${var.terraform_role_name}Policy"
  description = "Deployment permissions scoped for landing zone Terraform execution."
  policy      = data.aws_iam_policy_document.terraform_deploy.json
  tags        = var.tags
}

data "aws_iam_policy_document" "terraform_deploy" {
  statement {
    sid       = "TerraformLandingZoneAdministration"
    actions   = ["*"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "terraform" {
  role       = aws_iam_role.terraform.name
  policy_arn = aws_iam_policy.terraform_deploy.arn
}

resource "aws_iam_role" "break_glass" {
  name                 = var.break_glass_role_name
  assume_role_policy   = data.aws_iam_policy_document.assume_trusted.json
  permissions_boundary = var.permissions_boundary_arn
  tags                 = merge(var.tags, { AccessType = "Emergency" })
}

resource "aws_iam_role_policy_attachment" "break_glass" {
  role       = aws_iam_role.break_glass.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
