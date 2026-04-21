variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "analyst_email" {
  description = "Email address for SOC alert delivery"
  type        = string
}

variable "account_id" {
  description = "AWS account ID for topic policy scoping"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}