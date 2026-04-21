###############################################################################
# main.tf — Root configuration
# Calls all modules and wires them together
###############################################################################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "soc-terraform-state-905418310734"
    key     = "aws-soc/terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

###############################################################################
# Data Sources
###############################################################################

data "aws_caller_identity" "current" {}

###############################################################################
# Modules
###############################################################################

module "iam" {
  source      = "./iam"
  environment = var.environment
  common_tags = local.common_tags
}

module "cloudtrail" {
  source              = "./cloudtrail"
  environment         = var.environment
  account_id          = data.aws_caller_identity.current.account_id
  cloudtrail_role_arn = module.iam.cloudtrail_role_arn
  common_tags         = local.common_tags

  depends_on = [module.iam]
}

module "vpc" {
  source            = "./vpc"
  environment       = var.environment
  admin_ip_cidr     = var.admin_ip_cidr
  flow_log_role_arn = module.iam.vpc_flow_log_role_arn
  common_tags       = local.common_tags
  aws_region        = var.aws_region
  depends_on        = [module.iam]
  vpc_cidr          = var.vpc_cidr
  subnet_cidr       = var.subnet_cidr
}

module "ec2" {
  source               = "./ec2"
  environment          = var.environment
  key_pair_name        = var.key_pair_name
  subnet_id            = module.vpc.public_subnet_id
  security_group_id    = module.vpc.soc_victim_sg_id
  iam_instance_profile = module.iam.host_logging_instance_profile
  common_tags          = local.common_tags
  instance_type        = var.instance_type
  depends_on           = [module.vpc, module.iam]
}

module "sns" {
  source        = "./sns"
  environment   = var.environment
  analyst_email = var.analyst_email
  account_id    = data.aws_caller_identity.current.account_id
  common_tags   = local.common_tags
}

module "cloudwatch" {
  source          = "./cloudwatch"
  environment     = var.environment
  alarm_threshold = var.alarm_threshold
  sns_topic_arn   = module.sns.topic_arn
  common_tags     = local.common_tags

  depends_on = [module.sns]
}