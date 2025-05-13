data "aws_iam_policy_document" "meetings_lambda_additional_policy" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:DescribeStream",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:ListStreams",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query"
    ]

    resources = [
      "arn:aws:dynamodb:*:*:*:*"
    ]
  }
}

data "aws_iam_policy_document" "cognito_authorizer_lambda_additional_policy" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:*"
    ]

    resources = [
      module.cognito_secret.cognito_secret_arn
    ]
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
