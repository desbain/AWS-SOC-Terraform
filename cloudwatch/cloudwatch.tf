###############################################################################
# cloudwatch.tf — CloudWatch Module
# Creates: SOC-Auth-Logs log group, metric filter, brute force alarm
###############################################################################

# --- Auth Log Group ---
resource "aws_cloudwatch_log_group" "auth_logs" {
  name              = "SOC-Auth-Logs"
  retention_in_days = 90

  tags = var.common_tags
}

# --- Metric Filter ---
resource "aws_cloudwatch_log_metric_filter" "failed_ssh" {
  name           = "Failed-SSH-Attempts"
  log_group_name = aws_cloudwatch_log_group.auth_logs.name

  pattern = "? \"Invalid user\" ? \"Failed password\" ? \"Permission denied\" ? \"Connection closed\""

  metric_transformation {
    name          = "FailedPasswordCount"
    namespace     = "SOC/Authentication"
    value         = "1"
    default_value = "0"
  }
}

# --- Brute Force Alarm ---
resource "aws_cloudwatch_metric_alarm" "brute_force" {
  alarm_name          = "SOC-Brute-Force-Alert"
  alarm_description   = "Brute force SSH detected: ${var.alarm_threshold}+ failed attempts in 1 minute"
  metric_name         = "FailedPasswordCount"
  namespace           = "SOC/Authentication"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = var.alarm_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  alarm_actions = [var.sns_topic_arn]

  tags = var.common_tags

  depends_on = [aws_cloudwatch_log_metric_filter.failed_ssh]
}