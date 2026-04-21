###############################################################################
# cloudwatch/variables.tf
###############################################################################

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "alarm_threshold" {
  description = "Failed SSH attempts before alarm fires"
  type        = number
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for alarm notifications"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}