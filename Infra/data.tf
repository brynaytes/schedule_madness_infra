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