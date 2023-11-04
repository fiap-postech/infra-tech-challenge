output "output" {
  value = {
    cdn_url = "https://${aws_s3_bucket.cdn_bucket.bucket}.s3-website.${local.default_region}.amazonaws.com"
  }
}