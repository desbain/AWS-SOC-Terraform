output "host_logging_role_arn" {
  value = aws_iam_role.host_logging.arn
}

output "cloudtrail_role_arn" {
  value = aws_iam_role.cloudtrail_delivery.arn
}

output "vpc_flow_log_role_arn" {
  value = aws_iam_role.vpc_flow_logs.arn
}

output "host_logging_instance_profile" {
  value = aws_iam_instance_profile.host_logging.name
}
