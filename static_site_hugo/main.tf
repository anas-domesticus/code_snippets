data "aws_canonical_user_id" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "main" {
  bucket = var.domain_name

  policy = templatefile(
    "${path.module}/policy/main.json",
    {
      bucket_name                = var.domain_name
      oai_id                     = aws_cloudfront_origin_access_identity.this.id
      account_id                 = data.aws_caller_identity.current.account_id
    }
  )

  website {
    index_document = "index.html"
    error_document = "404.html"
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.main.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
