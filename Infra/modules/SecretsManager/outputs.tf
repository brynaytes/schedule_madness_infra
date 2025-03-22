output "cognito_secret_arn" {
    value = aws_secretsmanager_secret.secrets_manager.arn
}