###############################################################################
# outputs.tf — Root outputs surfaced after terraform apply
###############################################################################

output "ec2_public_ip" {
  description = "Public IP of SOC-Victim-Host"
  value       = module.ec2.public_ip
}

output "cloudtrail_bucket" {
  description = "S3 Evidence Locker bucket name"
  value       = module.cloudtrail.s3_bucket_name
}

output "sns_topic_arn" {
  description = "SOC Alert Notification topic ARN"
  value       = module.sns.topic_arn
}

output "alarm_arn" {
  description = "SOC Brute Force Alert alarm ARN"
  value       = module.cloudwatch.alarm_arn
}