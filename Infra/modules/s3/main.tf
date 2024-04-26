locals {
  s3_bucket_name = "${var.site_name}-site-assets"
}

resource "aws_s3_bucket" "site_bucket" {
  bucket = "${var.site_name}-site-assets"
  tags = {
    Name = var.site_name
  }
}



