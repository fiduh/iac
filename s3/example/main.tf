provider "aws" {
  region = local.region
}

locals {
  bucket_name = "s3-bk-tofu-demo"
  region      = "eu-west-1"
}

module "s3_bucket" {
  source = "../module"
  bucket = local.bucket_name

  attach_policy = false
  control_object_ownership = true

#   block_public_acls = false
#   block_public_policy = false
#   ignore_public_acls = false
#   restrict_public_buckets = false

  allow_public_access = false

  tags = {
    Owner = "OpenTofu"
  }

}