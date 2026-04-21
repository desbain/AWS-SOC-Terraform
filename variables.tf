####################################################################
# variables.tf - Root input variables definitions
# Actual values come from dev.tfvars
####################################################################

variable "aws_region" {
    description = "AWS region to deploy all SOC resources into"
    type = string
}

variable "environment" {
    description = "Deployment environment"
    type = string
}

variable "owner" {
    description = "Owner tag for all resources"
    type = string
}

variable "analyst_email" {
  description = "Email for SOC alert notifications"
  type        = string
}

variable "admin_ip_cidr" {
  description = "Your public IP in CIDR notation for SSH access"
  type        = string
}

variable "key_pair_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
}

variable "alarm_threshold" {
  description = "Failed SSH attempts before alarm fires"
  type        = number
}

variable "budget_limit" {
  description = "Monthly budget limit in USD"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the SOC VPC"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}


variable "instance_type" {
  description = "EC2 instance type for the victim server"
  type        = string
}