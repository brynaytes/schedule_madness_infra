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

module "cognito_secret" {
  source = "./modules/SecretsManager"
  secret_name = "${var.site_name}-${var.environment}-cognito-secret"
  Secret = { local : "enter value here"}
}

module "meetings_lambda" {
  source = "./modules/Lambda"
  lambda_function_name = "${var.site_name}-${var.environment}-meetings"
  target_project_folder = "meetings"
  additional_aws_iam_policy_document = data.aws_iam_policy_document.meetings_lambda_additional_policy.json
}

module "cognito_authorizer_lambda" {
  source = "./modules/Lambda"
  lambda_function_name = "${var.site_name}-${var.environment}-Cognito-Authorizer"
  target_project_folder = "Cognito-Authorizer"
  additional_aws_iam_policy_document = data.aws_iam_policy_document.cognito_authorizer_lambda_additional_policy.json
}

module "api_gateway" {
  source = "./modules/ApiGateway"
  environment = var.environment
  target_lambda_invoke_arn = module.meetings_lambda.lambda_invoke_arn
  target_lambda_name = "${var.site_name}-${var.environment}-meetings"
  accountId = data.aws_caller_identity.current.account_id
  myregion = data.aws_region.current.name
}