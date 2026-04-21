###############################################################################
# sns/outputs.tf
###############################################################################

output "topic_arn" {
  description = "SOC Alert Notification topic ARN"
  value       = aws_sns_topic.soc_alerts.arn
}

output "topic_name" {
  description = "SNS topic name"
  value       = aws_sns_topic.soc_alerts.name
}
