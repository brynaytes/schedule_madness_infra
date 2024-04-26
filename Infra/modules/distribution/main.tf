resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name              = var.site_bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = var.site_bucket_id
  }
  default_cache_behavior {
    allowed_methods        = ["POST", "HEAD", "PATCH", "DELETE", "PUT", "GET", "OPTIONS"]
    cached_methods         = ["HEAD", "GET", "OPTIONS"]
    viewer_protocol_policy = "allow-all"
    target_origin_id       = var.site_bucket_id
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

  }
  restrictions {
    geo_restriction {

      restriction_type = "none"
      locations        = []
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  tags = {
    Name = "Terraform hosting test"
  }
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "OAC for ${var.site_name}"
  description                       = ""
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}