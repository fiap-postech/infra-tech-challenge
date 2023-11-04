resource "aws_s3_bucket" "cdn_bucket" {
  bucket = local.bucket.name
  force_destroy = true

  tags = {
    Name = local.bucket.name
  }
}

resource "aws_s3_bucket_website_configuration" "cdn_website_configuration" {
  bucket = aws_s3_bucket.cdn_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_versioning" "cdn_versioning" {
  bucket = aws_s3_bucket.cdn_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "cdn_ownership_controls" {
  bucket = aws_s3_bucket.cdn_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "cdn_public_access_block" {
  bucket = aws_s3_bucket.cdn_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "cdn_bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.cdn_ownership_controls,
    aws_s3_bucket_public_access_block.cdn_public_access_block,
  ]

  bucket = aws_s3_bucket.cdn_bucket.id
  acl    = "public-read"
}