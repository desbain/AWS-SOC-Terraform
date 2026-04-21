# AWS-SOC-Terraform: Infrastructure as Code — SOC Pipeline

**Portfolio Pillar:** Cloud Security | Infrastructure as Code | CI/CD
**Status:** Complete
**Author:** [Your Name] | Cybersecurity Analyst | SOC Engineer
**IaC Tool:** Terraform >= 1.6.0
**AWS Provider:** hashicorp/aws ~> 5.0

> This project codifies the entire [AWS-SOC](../AWS-SOC/README.md) pipeline
> into reusable Terraform modules. One `terraform apply` provisions the
> complete SOC stack from scratch. No manual console steps. No configuration
> drift. Full reproducibility with GitHub Actions CI/CD.

---

## What This Demonstrates

| Capability | Implementation |
|---|---|
| Modular IaC | 6 independent reusable modules |
| Shared state | S3 backend — local and CI/CD use same state |
| CI/CD pipeline | GitHub Actions — plan on PR, apply on merge |
| Secret management | GitHub Secrets — no sensitive values in code |
| Multi-environment | dev.tfvars with different thresholds per env |
| Least privilege | IAM roles scoped to exact permissions needed |
| Zero manual bootstrap | CloudWatch Agent installed via EC2 user_data |
| IMDSv2 enforced | Prevents SSRF-based credential theft |
| Forensic-ready storage | S3 Evidence Locker — versioned, encrypted, no public access |
| Drift detection | terraform plan compares code against live AWS state |

---

## Architecture

---

## Repository Structure

AWS-SOC-Terraform/
│
├── main.tf                    # Root — orchestrates all modules
├── variables.tf               # All input variable definitions
├── outputs.tf                 # Surfaces key values after apply
├── locals.tf                  # Shared tags — defined once, used everywhere
├── dev.tfvars                 # Dev environment values (gitignored)
│
├── iam/
│   ├── iam.tf                 # SOC-Host-Logging-Role, delivery roles
│   ├── variables.tf
│   └── outputs.tf
│
├── cloudtrail/
│   ├── cloudtrail.tf          # Trail, S3 Evidence Locker, CW integration
│   ├── variables.tf
│   └── outputs.tf
│
├── vpc/
│   ├── vpc.tf                 # VPC, subnet, IGW, SOC-Victim-SG, Flow Logs
│   ├── variables.tf
│   └── outputs.tf
│
├── ec2/
│   ├── ec2.tf                 # SOC-Victim-Host + CloudWatch Agent bootstrap
│   ├── variables.tf
│   └── outputs.tf
│
├── cloudwatch/
│   ├── cloudwatch.tf          # Log group, metric filter, brute-force alarm
│   ├── variables.tf
│   └── outputs.tf
│
├── sns/
│   ├── sns.tf                 # Alert topic + email subscription
│   ├── variables.tf
│   └── outputs.tf
│
└── .github/workflows/
├── terraform.yml          # Plan on PR, apply on merge to main
└── terraform-destroy.yml  # Manual destroy with confirmation gate

---

## Prerequisites

- Terraform >= 1.6.0
- AWS CLI configured with SOC_Admin credentials
- An existing EC2 key pair named `SOC-Project-Key` in `us-east-2`
- Your public IP (`curl ifconfig.me`)

---

## Quick Start

```bash
# Clone the repo
git clone https://github.com/desbain/AWS-SOC-Terraform.git
cd AWS-SOC-Terraform

# Create your values file (gitignored)
cp dev.tfvars.example dev.tfvars
# Edit: admin_ip_cidr, analyst_email

# Initialise Terraform
terraform init

# Preview what will be created
terraform plan -var-file="dev.tfvars"

# Deploy the full SOC stack
terraform apply -var-file="dev.tfvars"

# View outputs
terraform output soc_pipeline_summary
```

---

## CI/CD Pipeline

Push to feature branch
↓
Pull Request created
↓
GitHub Actions runs automatically:
✅ terraform fmt -check
✅ terraform validate
✅ terraform plan (shows diff as PR comment)
✅ GitGuardian secret scan
✅ SonarCloud quality gate
↓
PR reviewed and merged to main
↓
Production approval gate (human review required)
↓
terraform apply deploys to AWS
↓
Outputs: EC2 IP, SNS ARN, CloudTrail bucket

### GitHub Secrets Required

| Secret | Description |
|---|---|
| `AWS_ACCESS_KEY_ID` | SOC_Admin access key |
| `AWS_SECRET_ACCESS_KEY` | SOC_Admin secret key |
| `TF_VAR_analyst_email` | Alert notification email |
| `TF_VAR_admin_ip_cidr` | Your IP in CIDR notation |

---

## Key Engineering Decisions

**Why modules?**
Each module maps to a security domain. A flat config is unreviable and non-reusable. Modules let you test, version, and replace each layer independently.

**Why S3 backend?**
Without shared state, the CI/CD pipeline and local machine would have separate state files and try to recreate existing resources. S3 backend gives both environments a single source of truth.

**Why IMDSv2?**
IMDSv2 requires a PUT request with a custom header before returning instance metadata. SSRF attacks cannot forge PUT requests — the IAM role credentials on the instance are protected from web application vulnerabilities.

**Why `force_destroy = false` on S3?**
If Terraform accidentally ran destroy, you'd lose your forensic audit trail. This safeguard means Terraform refuses to delete the bucket if it contains objects.

**Why `dev.tfvars` is gitignored?**
It contains your IP address and email. Sensitive values never appear in Git history. GitHub Secrets injects them into the pipeline at runtime.

---

## Modules Summary

| Module | Resources Created | Key Security Decision |
|---|---|---|
| IAM | 3 roles, instance profile | Least privilege — CloudWatch write only |
| CloudTrail | Trail, S3 bucket, CW log group | Integrity validation, encrypted, no public access |
| VPC | VPC, subnet, IGW, SG, Flow Logs | SSH locked to /32, 1-min aggregation |
| EC2 | Ubuntu 24.04 instance | IMDSv2, user_data bootstrap, encrypted EBS |
| CloudWatch | Log group, metric filter, alarm | Threshold=3, 1-min window, notBreaching |
| SNS | Topic, policy, subscription | CloudWatch publish policy scoped to account |

---

## Teardown

```bash
terraform destroy -var-file="dev.tfvars"
```

> Note: S3 Evidence Locker must be emptied manually before destroy completes.

---

## Related Projects

| Project | Description |
|---|---|
| [AWS-SOC](../AWS-SOC/README.md) | Manual build — the baseline this codifies |
| [AWS-SOC-Kubernetes](../AWS-SOC-Kubernetes/README.md) | Container-native re-architecture |