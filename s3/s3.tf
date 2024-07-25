data "aws_caller_identity" "current" {}

# S3 Bucket
resource "aws_s3_bucket" "this" {
  bucket = "s3-tofu-logs-bucket"
}


# Resourse Policy - Datasource
data "aws_iam_policy_document" "cloudtrail_policy" {
  statement {
    effect = "Allow"

    actions = ["s3:PutObject"]

    resources = ["${aws_s3_bucket.this.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketAcl",
      "s3:ListBucket"
    ]

    resources = ["${aws_s3_bucket.this.arn}"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}


# Resource Policy
resource "aws_s3_bucket_policy" "cloudtrail_policy" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.cloudtrail_policy.json
}
