################################################################################
# locals.tf shared tags applied to every resource
################################################################################

locals {
    common_tags = {
        Project = "AWS-SOC"
        Environment = var.environment
        ManagedBy = "Terraform"
    }
}