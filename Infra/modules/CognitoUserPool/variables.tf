
variable "callback_URLs" {
    type = list(string)
}
variable "app_name" {
    type = string
}
variable "token_experations" {
    type = number
    default = 30
    description = "Number of days the tokens will be valid for."
}


variable "logout_URLs" {
    type = list(string)
}