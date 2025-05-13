output "distribution_arn" {
  value = aws_cloudfront_distribution.distribution.arn
}

output "distribution_url" {
  value = aws_cloudfront_distribution.distribution.domain_name
}