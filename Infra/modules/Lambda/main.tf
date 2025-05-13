resource "aws_lambda_function" "lambda" {
  function_name = var.lambda_function_name
  filename      = "${path.root}/compressed/${var.lambda_function_name}_lambda_payload.zip"
  handler       = "index.handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime = "nodejs20.x"

  role = aws_iam_role.iam_for_lambda.arn
  
  # ... other configuration ...
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.logGroup,
    aws_iam_role.iam_for_lambda,
    aws_iam_policy.lambda_logging,
  ]
}

# This is to optionally manage the CloudWatch Log Group for the Lambda Function.
# If skipping this resource configuration, also add "logs:CreateLogGroup" to the IAM policy below.
resource "aws_cloudwatch_log_group" "logGroup" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:log-group:*",
      "arn:aws:logs:*:*:log-group:*:log-stream:*"
    ]
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging_${var.lambda_function_name}_${random_string.suffix.result}"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.root}/../BackEndMocking/src/${var.target_project_folder}/index.mjs"
  output_path = "${path.root}/compressed/${var.lambda_function_name}_lambda_payload.zip"
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_${var.lambda_function_name}_${random_string.suffix.result}"
  assume_role_policy =  jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}


resource "aws_iam_policy" "lambda_additional_iam_policy" {
  count = var.additional_aws_iam_policy_document != null ? 1 : 0
  name        = "lambda_additional_iam_policy_${var.lambda_function_name}_${random_string.suffix.result}"
  description = "IAM policy for a lambda"
  policy      = var.additional_aws_iam_policy_document
}

resource "aws_iam_role_policy_attachment" "lambda_additional_policy_attachment" {
  count = var.additional_aws_iam_policy_document != null ? 1 : 0
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_additional_iam_policy[0].arn
    depends_on = [
      aws_iam_policy.lambda_additional_iam_policy
    ]
}

resource "random_string" "suffix" {
  length = 4
  special = false
}