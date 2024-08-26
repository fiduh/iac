resource "aws_s3_bucket" "this" {
  bucket        = var.bucket

  force_destroy       = var.force_destroy
  tags                = var.tags
}

resource "aws_s3_bucket_ownership_controls" "this" {
  count =  var.control_object_ownership ? 1 : 0

  bucket =  aws_s3_bucket.this.id

  rule {
    object_ownership = var.object_ownership
  }

  # This `depends_on` is to prevent "A conflicting conditional operation is currently in progress against this resource."
  depends_on = [
    aws_s3_bucket_policy.this,
    aws_s3_bucket_public_access_block.this,
    aws_s3_bucket.this
  ]
}

resource "aws_s3_bucket_public_access_block" "this" {
  count = var.attach_public_policy ? 1 : 0

  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}
data "aws_iam_policy_document" "combined" {
  count = var.attach_policy ? 1 : 0

  source_policy_documents = compact([
    var.attach_public_policy ? data.aws_iam_policy_document.allow_public_access[0].json : "",
  ])
}

data "aws_iam_policy_document" "allow_public_access" {
  count =  var.allow_public_access ? 1 : 0
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

resource "aws_s3_bucket_policy" "this" {
  count = var.attach_policy ? 1 : 0

  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.combined[0].json

  depends_on = [
    aws_s3_bucket_public_access_block.this
  ]
}