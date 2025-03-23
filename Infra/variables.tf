variable "site_name" {
  type        = string
  default     = "scheduler-madness"
  description = "Name of the site."
}

variable "environment" {
  type = string
  default = "dev"
  description = "Name of environment to be added to the resources"
}