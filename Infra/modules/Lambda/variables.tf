variable "lambda_function_name" {
    type = string
}

variable "target_project_folder" {
    type = string 
}

variable "additional_aws_iam_policy_document" {
    type = string
    nullable = true
}