###############################################################################
# vpc.tf — VPC Module
# Creates: VPC, public subnet, IGW, route table,
#          SOC-Victim-SG, VPC Flow Logs
###############################################################################

# --- VPC ---
resource "aws_vpc" "soc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.common_tags, {
    Name = "SOC-Project-VPC-${var.environment}"
  })
}

# --- Public Subnet ---
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.soc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = merge(var.common_tags, {
    Name = "SOC-Public-Subnet-${var.environment}"
  })
}

# --- Internet Gateway ---
resource "aws_internet_gateway" "soc" {
  vpc_id = aws_vpc.soc.id

  tags = merge(var.common_tags, {
    Name = "SOC-IGW-${var.environment}"
  })
}

# --- Route Table ---
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.soc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.soc.id
  }

  tags = merge(var.common_tags, {
    Name = "SOC-Public-RT-${var.environment}"
  })
}

# --- Route Table Association ---
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# --- Security Group ---
resource "aws_security_group" "soc_victim" {
  name        = "SOC-Victim-SG-${var.environment}"
  description = "SSH locked to admin IP. HTTP open for attack surface simulation."
  vpc_id      = aws_vpc.soc.id

  ingress {
    description = "SSH from admin IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip_cidr]
  }

  ingress {
    description = "HTTP open to simulate public web service"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound for CloudWatch Agent"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "SOC-Victim-SG-${var.environment}"
  })
}

# --- VPC Flow Logs ---
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "VPC-Flow-Logs-${var.environment}"
  retention_in_days = 90

  tags = var.common_tags
}

resource "aws_flow_log" "soc" {
  vpc_id          = aws_vpc.soc.id
  traffic_type    = "ALL"
  iam_role_arn    = var.flow_log_role_arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn

  max_aggregation_interval = 60

  tags = merge(var.common_tags, {
    Name = "SOC-Network-Traffic-Logs-${var.environment}"
  })
}