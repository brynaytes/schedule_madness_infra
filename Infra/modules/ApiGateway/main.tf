# Variables
variable "myregion" {}

variable "accountId" {}

# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "meetings-${var.environment}"
  
}

resource "aws_api_gateway_resource" "meeting_resource" {
  path_part   = "meetings"
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "meeting_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.meeting_resource.id
  http_method   = "POST"
  authorization = "NONE"
}


resource "aws_api_gateway_integration" "meeting_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.meeting_resource.id
  http_method             = aws_api_gateway_method.meeting_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.meeting_lambda_invoke_arn
}


# Lambda
resource "aws_lambda_permission" "meeting_apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.meeting_lambda_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.myregion}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.meeting_method.http_method}${aws_api_gateway_resource.meeting_resource.path}"
}


# IAM
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role" {
  name               = "meetings_${var.environment}_${random_string.suffix.result}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "random_string" "suffix" {
  length = 4
  special = false
}


resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api.body))
  }
  depends_on = [ aws_api_gateway_method.user_method,aws_api_gateway_method.meeting_method ]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "${var.environment}"
}

module "meetings_options" {
  source = "../ApiGatewayAddOptions"
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.meeting_resource.id
}


resource "aws_api_gateway_resource" "user_resource" {
  path_part   = "user"
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "user_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.user_resource.id
  http_method   = "POST"
  authorization = "NONE"
}


resource "aws_api_gateway_integration" "user_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.user_resource.id
  http_method             = aws_api_gateway_method.user_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.user_lambda_invoke_arn
}

resource "aws_api_gateway_resource" "login_resource" {
  path_part   = "login"
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_resource" "login_proxy_resource" {
  path_part   = "{code}"
  parent_id   = aws_api_gateway_resource.login_resource.id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "login_proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.login_proxy_resource.id
  http_method   = "POST"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}


resource "aws_api_gateway_integration" "login_proxy_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.login_proxy_resource.id
  http_method             = aws_api_gateway_method.login_proxy_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.authorizer_lambda_invoke_arn
  depends_on = [ aws_api_gateway_resource.login_resource,aws_api_gateway_resource.login_proxy_resource ]
}

# Lambda
resource "aws_lambda_permission" "user_apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.user_lambda_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.myregion}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.user_method.http_method}${aws_api_gateway_resource.user_resource.path}"
}

module "user_options" {
  source = "../ApiGatewayAddOptions"
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.user_resource.id
}

module "login_proxy_options" {
  source = "../ApiGatewayAddOptions"
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.login_proxy_resource.id
}
