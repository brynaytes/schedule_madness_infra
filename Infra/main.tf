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
  Secret = { local : module.cognito_user_pool.client_secret}
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

module "cognito_user_lambda" {
  source = "./modules/Lambda"
  lambda_function_name = "${var.site_name}-${var.environment}-Cognito-User"
  target_project_folder = "Cognito-User"
  additional_aws_iam_policy_document = data.aws_iam_policy_document.cognito_authorizer_lambda_additional_policy.json
}

module "api_gateway" {
  source = "./modules/ApiGateway"
  environment = var.environment
  meeting_lambda_invoke_arn = module.meetings_lambda.lambda_invoke_arn
  meeting_lambda_name = "${var.site_name}-${var.environment}-meetings"
  accountId = data.aws_caller_identity.current.account_id
  myregion = data.aws_region.current.name
  authorizer_lambda_invoke_arn = module.cognito_authorizer_lambda.lambda_invoke_arn
  authorizer_lambda_name =  "${var.site_name}-${var.environment}-Cognito-Authorizer"
  user_lambda_invoke_arn = module.cognito_user_lambda.lambda_invoke_arn
  user_lambda_name = "${var.site_name}-${var.environment}-Cognito-User"
}

variable "meeting_availability_definition" {
  type = list(map(string))
  default = [
    {
      name = "MeetingID"
      type = "S"
    },
    {
      name = "DateTimeID"
      type = "S"
    }
  ]
}
module "meeting_availability_dynamo_table" {
  source = "./modules/DynamoDB"
  table_name = "${var.site_name}-${var.environment}-MeetingAvailability"
  attributes = var.meeting_availability_definition
  partition_key = "MeetingID"
  sort_key = "DateTimeID"
}

variable "meeting_info_definition" {
  type = list(map(string))
  default = [
    {
      name = "MeetingID"
      type = "S"
    },
    {
      name = "UserID"
      type = "S"
    }
  ]
}

module "meeting_info_dynamo_table" {
  source = "./modules/DynamoDB"
  table_name = "${var.site_name}-${var.environment}-MeetingInfo"
  attributes = var.meeting_info_definition
  partition_key = "MeetingID"
  sort_key = "UserID"
  secondary_index = true
  secondary_partitan_key =  "UserID"
  secondary_sort_key = "MeetingID"
}

module "cognito_user_pool" {
  source = "./modules/CognitoUserPool"
  callback_URLs = [ "http://localhost:4200/login" , "https://www.${module.cf_distribution.distribution_url}/login"]
  logout_URLs = [ "http://localhost:4200/logout" , "https://www.${module.cf_distribution.distribution_url}/logout"]

  app_name = "${var.site_name}-${var.environment}"
}