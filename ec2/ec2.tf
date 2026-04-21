###############################################################################
# ec2.tf — EC2 Module
# Creates: SOC-Victim-Host (Ubuntu 24.04 LTS)
# Bootstraps: CloudWatch Agent via user_data
###############################################################################

# --- Get Latest Ubuntu 24.04 AMI ---
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# --- EC2 Instance ---
resource "aws_instance" "soc_victim" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.iam_instance_profile

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -euo pipefail

    # Install CloudWatch Agent
    wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb \
      -O /tmp/amazon-cloudwatch-agent.deb
    dpkg -i -E /tmp/amazon-cloudwatch-agent.deb

    # Add cwagent to adm group for auth.log access
    usermod -a -G adm cwagent

    # Write agent config
    mkdir -p /opt/aws/amazon-cloudwatch-agent/bin
    cat <<'CWCONFIG' > /opt/aws/amazon-cloudwatch-agent/bin/config.json
    {
      "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "cwagent"
      },
      "logs": {
        "logs_collected": {
          "files": {
            "collect_list": [
              {
                "file_path": "/var/log/auth.log",
                "log_group_name": "SOC-Auth-Logs",
                "log_stream_name": "{instance_id}",
                "timezone": "UTC",
                "timestamp_format": "%b %d %H:%M:%S"
              }
            ]
          }
        }
      }
    }
    CWCONFIG

    # Start CloudWatch Agent
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
      -a fetch-config -m ec2 -s \
      -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json
  EOF
  )

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = merge(var.common_tags, {
    Name    = "SOC-Victim-Host-${var.environment}"
    Purpose = "Security sensor — auth.log streaming to CloudWatch"
  })
}