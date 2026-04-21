###############################################################################
# vpc/outputs.tf
###############################################################################

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.soc.id
}

output "public_subnet_id" {
  description = "Public subnet ID for EC2 placement"
  value       = aws_subnet.public.id
}

output "soc_victim_sg_id" {
  description = "Security Group ID for SOC-Victim-Host"
  value       = aws_security_group.soc_victim.id
}

output "flow_log_group_name" {
  description = "VPC Flow Logs CloudWatch log group name"
  value       = aws_cloudwatch_log_group.vpc_flow_logs.name
}