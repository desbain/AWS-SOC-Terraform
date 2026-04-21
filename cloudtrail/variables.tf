variable "environment" {
    description = "Deployment environment"
    type = string
}

variable "account_id" {
  description = "AWS account ID for trail naming"
  type        = string
}

variable "cloudtrail_role_arn" {
  description = "ARN of the CloudTrail delivery role"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}