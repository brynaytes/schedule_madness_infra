module "s3" {
  source    = "./modules/s3"
  site_name = var.site_name
}

module "cf_distribution" {
  source                  = "./modules/distribution"
  site_name               = var.site_name
  site_bucket_id          = module.s3.s3_id
  site_bucket_domain_name = module.s3.s3_domain_name
}

module "s3_policy" {
  source         = "./modules/s3_policy"
  s3_bucket_name = "${var.site_name}-site-assets"
  s3_bucket_id   = module.s3.s3_id
  cloudfront_arn = module.cf_distribution.distribution_arn
}