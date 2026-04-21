###############################################################################
# sns.tf — SNS Module
# Creates: SOC-Alert-Notification topic + email subscription
###############################################################################

# --- SNS Topic ---
resource "aws_sns_topic" "soc_alerts" {
  name = "SOC-Alert-Notification-${var.environment}"

  tags = var.common_tags
}

# --- Topic Policy ---
resource "aws_sns_topic_policy" "allow_cloudwatch" {
  arn = aws_sns_topic.soc_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchAlarmPublish"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.soc_alerts.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:cloudwatch:*:${var.account_id}:alarm:*"
          }
        }
      }
    ]
  })
}

# --- Email Subscription ---
resource "aws_sns_topic_subscription" "analyst_email" {
  topic_arn = aws_sns_topic.soc_alerts.arn
  protocol  = "email"
  endpoint  = var.analyst_email
}