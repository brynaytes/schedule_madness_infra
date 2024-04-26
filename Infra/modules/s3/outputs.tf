output "s3_domain_name" {
  value = aws_s3_bucket.site_bucket.bucket_regional_domain_name
}

output "s3_id" {
  value = aws_s3_bucket.site_bucket.id
}