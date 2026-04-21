###############################################################################
# ec2/variables.tf
###############################################################################

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_pair_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID from VPC module"
  type        = string
}

variable "security_group_id" {
  description = "Security Group ID from VPC module"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile name from IAM module"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}