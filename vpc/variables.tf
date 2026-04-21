###############################################################################
# vpc/variables.tf
###############################################################################

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "aws_region" {
  description = "AWS region for availability zone"
  type        = string
}

variable "admin_ip_cidr" {
  description = "Admin IP in CIDR notation for SSH access"
  type        = string
}

variable "flow_log_role_arn" {
  description = "IAM role ARN for VPC Flow Logs delivery"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}

variable "vpc_cidr" {
  description = "CIDR block for the SOC project VPC"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}