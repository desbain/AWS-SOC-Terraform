###############################################################################
# iam.tf — IAM Module
# Creates: SOC-Host-Logging-Role, CloudTrail delivery role,
#          VPC Flow Logs delivery role, instance profile
###############################################################################

# --- EC2 Host Logging Role ---
resource "aws_iam_role" "host_logging" {
  name               = "SOC-Host-Logging-Role-${var.environment}"
  description        = "Allows SOC-Victim-Host to stream auth.log to CloudWatch only"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = var.common_tags
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.host_logging.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "host_logging" {
  name = "SOC-Host-Logging-Profile-${var.environment}"
  role = aws_iam_role.host_logging.name
}

# --- CloudTrail Delivery Role ---
resource "aws_iam_role" "cloudtrail_delivery" {
  name               = "SOC-CloudTrail-CWLogs-Role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json

  tags = var.common_tags
}

data "aws_iam_policy_document" "cloudtrail_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "cloudtrail_delivery" {
  name = "cloudtrail-cw-delivery"
  role = aws_iam_role.cloudtrail_delivery.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
      Resource = "*"
    }]
  })
}

# --- VPC Flow Logs Delivery Role ---
resource "aws_iam_role" "vpc_flow_logs" {
  name               = "SOC-VPC-FlowLogs-Role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_assume_role.json

  tags = var.common_tags
}

data "aws_iam_policy_document" "vpc_flow_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  name = "vpc-flow-logs-to-cloudwatch"
  role = aws_iam_role.vpc_flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Resource = "*"
    }]
  })
}