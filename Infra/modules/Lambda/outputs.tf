output "lambda_name" {
  value = var.lambda_function_name
}
output "lambda_invoke_arn" {
  value = aws_lambda_function.lambda.invoke_arn
}