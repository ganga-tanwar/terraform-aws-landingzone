terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket         = "REPLACE_WITH_STATE_BUCKET"
    key            = "environments/dev/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
