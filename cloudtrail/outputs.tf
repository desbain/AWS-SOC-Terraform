###############################################################################
# cloudtrail/outputs.tf
###############################################################################

output "s3_bucket_name" {
  description = "Evidence Locker S3 bucket name"
  value       = aws_s3_bucket.evidence_locker.bucket
}

output "trail_arn" {
  description = "CloudTrail trail ARN"
  value       = aws_cloudtrail.soc_audit.arn
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group for CloudTrail"
  value       = aws_cloudwatch_log_group.cloudtrail.name
}