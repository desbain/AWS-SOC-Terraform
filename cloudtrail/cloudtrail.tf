###############################################################################
# cloudtrail.tf — CloudTrail Module
# Creates: S3 Evidence Locker, CloudTrail trail, CloudWatch log group
###############################################################################

# --- S3 Evidence Locker ---
resource "aws_s3_bucket" "evidence_locker" {
  bucket        = "soc-audit-trail-${var.account_id}-${var.environment}"
  force_destroy = false

  tags = var.common_tags
}

resource "aws_s3_bucket_versioning" "evidence_locker" {
  bucket = aws_s3_bucket.evidence_locker.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "evidence_locker" {
  bucket                  = aws_s3_bucket.evidence_locker.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "evidence_locker" {
  bucket = aws_s3_bucket.evidence_locker.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_delivery" {
  bucket = aws_s3_bucket.evidence_locker.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.evidence_locker.arn
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.evidence_locker.arn}/AWSLogs/${var.account_id}/*"
        Condition = {
          StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" }
        }
      }
    ]
  })
}

# --- CloudWatch Log Group ---
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "aws-cloudtrail-logs-${var.environment}"
  retention_in_days = 90

  tags = var.common_tags
}

# --- CloudTrail Trail ---
resource "aws_cloudtrail" "soc_audit" {
  name                          = "SOC-Audit-Trail-${var.environment}"
  s3_bucket_name                = aws_s3_bucket.evidence_locker.id
  include_global_service_events = true
  is_multi_region_trail         = false
  enable_log_file_validation    = true

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn  = var.cloudtrail_role_arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  tags = var.common_tags

  depends_on = [aws_s3_bucket_policy.cloudtrail_delivery]
}