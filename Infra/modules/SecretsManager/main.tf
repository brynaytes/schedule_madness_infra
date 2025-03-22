variable "Secret" {
  default = {
    local = "enter secret value here"
  }

  type = map(string)
}


resource "aws_secretsmanager_secret" "secrets_manager" {
  name = var.secret_name
}

resource "aws_secretsmanager_secret_version" "secret" {
  secret_id = aws_secretsmanager_secret.secrets_manager.id
  secret_string = jsonencode(var.Secret)
}