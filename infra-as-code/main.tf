terraform {
  required_version = "~> 1.1.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.30.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.2.3"
    }
  }
}

module "init-environments" {
  for_each              = toset(var.environments)
  source                = "github.com/Thaeimos/terraform-init-envs/?ref=v1.0.0"
  environment           = each.value
  s3_bucket_prefix      = var.s3_bucket_prefix
  s3_bucket_name        = var.s3_bucket_name
  dynamodb_table        = var.dynamodb_table
  bucket_sse_algorithm  = var.bucket_sse_algorithm
}
