# Configure the AWS Provider
provider "aws"{
  region = "us-east-1"
}


#data "aws_caller_identity" "current" {}

# Create the S3 Bucket
resource "aws_s3_bucket" "this" {
  bucket = "s3-tofu-logs-bucket"
}

# Set S3 Bucket Ownership Controls
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Configure Public Access Block Settings
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = false # Allows public ACLs
  block_public_policy     = false # Allows public bucket policies
  ignore_public_acls      = false # Does not ignore public ACLs
  restrict_public_buckets = false # Does not restrict public buckets
}


# Create the Bucket Policy Document using a Data Source
data "aws_iam_policy_document" "allow_public_access" {
  statement {
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:GetObject"]

    resources = ["${aws_s3_bucket.this.arn}/*"] # Grants public access to all objects within the bucket
  }
}

# Attach the Policy to the S3 Bucket
resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.allow_public_access.json
}

