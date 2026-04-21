###############################################################################
# cloudwatch/outputs.tf
###############################################################################

output "alarm_arn" {
  description = "SOC Brute Force Alert alarm ARN"
  value       = aws_cloudwatch_metric_alarm.brute_force.arn
}

output "auth_log_group_name" {
  description = "SOC Auth Logs log group name"
  value       = aws_cloudwatch_log_group.auth_logs.name
}

output "metric_filter_name" {
  description = "Failed SSH Attempts metric filter name"
  value       = aws_cloudwatch_log_metric_filter.failed_ssh.name
}