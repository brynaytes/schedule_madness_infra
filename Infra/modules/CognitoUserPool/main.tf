resource "aws_cognito_user_pool_client" "client" {
  name = "${var.app_name}-client"

  user_pool_id                         = aws_cognito_user_pool.pool.id
  callback_urls                        = var.callback_URLs
  logout_urls                       = var.logout_URLs
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["email", "openid", "phone", "profile", "aws.cognito.signin.user.admin"]
  allowed_oauth_flows                  = ["code", "implicit"]
  supported_identity_providers         = ["COGNITO"]
  generate_secret     = true

}

resource "aws_cognito_user_pool" "pool" {
  name = "${var.app_name}-pool"
}

resource "aws_cognito_user_pool_domain" "pool_domain" {
  domain       = var.app_name
  user_pool_id = aws_cognito_user_pool.pool.id
}
/*
resource "aws_cognito_user_pool_ui_customization" "pool_customization" {
 user_pool_id = aws_cognito_user_pool_domain.pool_domain.user_pool_id
}*/
