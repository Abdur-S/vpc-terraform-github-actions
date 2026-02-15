# VPC Infrastructure with Terraform and GitHub Actions CI/CD

## 📋 Project Overview

A complete **Infrastructure as Code (IaC)** project demonstrating enterprise-grade AWS VPC deployment using **Terraform** with automated **GitHub Actions CI/CD pipeline**. This project showcases DevOps best practices including modular architecture, infrastructure automation, and continuous deployment.

### 🎯 What This Project Demonstrates

**Technical Skills:**
- ✅ Infrastructure as Code (Terraform 1.0+)
- ✅ AWS Cloud Services (VPC, EC2, ALB, Security Groups)
- ✅ CI/CD Automation (GitHub Actions)
- ✅ Network Architecture & Security
- ✅ Modular Terraform Design Patterns
- ✅ Cloud Deployment & Troubleshooting
- ✅ DevOps Best Practices

---

## 🏗️ Infrastructure Architecture

### Deployed AWS Resources

```
Architecture Overview:
┌─────────────────────────────────────────────────────────────────┐
│                    AWS VPC (10.0.0.0/16)                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────┐  ┌──────────────────┐                    │
│  │ Public Subnet 1  │  │ Public Subnet 2  │                    │
│  │ (10.0.1.0/24)    │  │ (10.0.2.0/24)    │                    │
│  │                  │  │                  │                    │
│  │ ┌──────────────┐ │  │ ┌──────────────┐ │                    │
│  │ │  EC2 Instance│ │  │ │  EC2 Instance│ │                    │
│  │ │  t2.micro    │ │  │ │  t2.micro    │ │                    │
│  │ │  Apache Web  │ │  │ │  Apache Web  │ │                    │
│  │ └──────────────┘ │  │ └──────────────┘ │                    │
│  └──────────────────┘  └──────────────────┘                    │
│           │                      │                              │
│           └──────────┬───────────┘                              │
│                      ▼                                           │
│         ┌────────────────────────┐                              │
│         │  Application Load      │                              │
│         │  Balancer (ALB)        │                              │
│         │  Port 80               │                              │
│         └────────────────────────┘                              │
│                      │                                           │
│                      ▼                                           │
│         ┌────────────────────────┐                              │
│         │   Internet Gateway     │                              │
│         │   (IGW)                │                              │
│         └────────────────────────┘                              │
│                      │                                           │
└──────────────────────┼──────────────────────────────────────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │   Internet/Users     │
            │   Port 80 HTTP       │
            └──────────────────────┘
```

### AWS Resources Deployed

| Resource | Configuration | Purpose |
|----------|---------------|---------|
| **VPC** | CIDR: 10.0.0.0/16 | Main network container |
| **Public Subnets** | 2 subnets (10.0.1.0/24, 10.0.2.0/24) | Multi-AZ deployment for HA |
| **Internet Gateway** | Attached to VPC | Enables internet connectivity |
| **Route Tables** | Public route table with IGW | Routes traffic to internet |
| **Security Group** | HTTP/HTTPS/SSH ingress | Controls inbound/outbound traffic |
| **EC2 Instances** | t2.micro, Amazon Linux 2, ×2 | Web servers with Apache HTTP |
| **Application Load Balancer** | Port 80, target groups | Distributes traffic across instances |
| **Target Groups** | Health checks (HTTP 200) | Manages backend servers |

---

## 📁 Project Structure & Modules

### Modular Terraform Design

```
vpc-terraform-github-actions/
├── README.md                          # Project documentation
├── Terraform-VPC/
│   ├── main.tf                        # Root module orchestration
│   ├── provider.tf                    # AWS provider configuration
│   ├── terraform.tfvars               # Variable values (VPC CIDR, subnets)
│   ├── variables.tf                   # Root variables
│   ├── outputs.tf                     # Root outputs (aggregates module outputs)
│   │
│   └── modules/                       # Modular infrastructure components
│       │
│       ├── vpc/                       # Network foundation module
│       │   ├── main.tf                # VPC, subnets, IGW, route tables
│       │   ├── data.tf                # AWS availability zones lookup
│       │   ├── variables.tf           # CIDR inputs
│       │   └── outputs.tf             # VPC ID, subnet IDs outputs
│       │
│       ├── sg/                        # Security group module
│       │   ├── main.tf                # Ingress/egress rules (HTTP/HTTPS/SSH)
│       │   ├── variables.tf           # VPC ID input
│       │   └── outputs.tf             # Security group ID output
│       │
│       ├── ec2/                       # Compute module
│       │   ├── main.tf                # 2 EC2 instances with userdata
│       │   ├── data.tf                # AMI lookup, availability zones
│       │   ├── variables.tf           # Security group, subnets, instance names
│       │   └── outputs.tf             # Instance IDs output
│       │
│       └── alb/                       # Load balancer module
│           ├── main.tf                # ALB, listeners, target groups
│           ├── variables.tf           # VPC, subnets, instance IDs inputs
│           └── outputs.tf             # ALB DNS name, ARN outputs
│
└── .github/
    └── workflows/
        └── deploy.yml                 # GitHub Actions CI/CD pipeline
```

### Module Breakdown

#### 1️⃣ **VPC Module** (`modules/vpc/`)
**Purpose:** Foundation networking layer

**Key Features:**
- Custom VPC with configurable CIDR block
- Multi-AZ public subnets using `count` meta-argument
- Internet Gateway for public internet access
- Route tables with internet routes
- Automatic availability zone discovery via data source

**Key Files:**
- `main.tf`: Creates VPC, subnets, IGW, route tables, route associations
- `data.tf`: Queries AWS for available AZs in region
- `variables.tf`: vpc_cidr, subnet_cidr, subnet_names variables
- `outputs.tf`: Exposes vpc_id, subnet_ids, route_table_id

---

#### 2️⃣ **Security Group Module** (`modules/sg/`)
**Purpose:** Access control and network security

**Key Features:**
- HTTP access on port 80 (for web traffic via ALB)
- HTTPS access on port 443 (future-ready)
- SSH access on port 22 (for administration)
- Allow-all egress for outbound traffic
- Security group sourced from VPC module

**Ingress Rules:**
```
HTTP:  0.0.0.0/0 → :80   (All internet)
HTTPS: 0.0.0.0/0 → :443  (All internet)
SSH:   0.0.0.0/0 → :22   (All internet - should restrict in production)
```

**Key Files:**
- `main.tf`: Defines security group with ingress/egress rules
- `variables.tf`: vpc_id input variable
- `outputs.tf`: Exports sg_id for use by EC2 and ALB modules

---

#### 3️⃣ **EC2 Module** (`modules/ec2/`)
**Purpose:** Compute layer with web servers

**Key Features:**
- 2 EC2 instances deployed across availability zones (high availability)
- Amazon Linux 2 AMI (optimized, free-tier eligible)
- t2.micro instance type (cost-effective, free-tier eligible)
- Automatic userdata script for Apache HTTP Server setup
- Instances automatically placed in public subnets

**Userdata Script Responsibilities:**
```bash
1. Update system packages
2. Install Apache HTTP Server (httpd)
3. Enable httpd to start on boot
4. Start httpd service
5. Create basic HTML dashboard page
6. Wait for service startup before health checks
```

**Key Files:**
- `main.tf`: EC2 instance resources with count-based deployment
- `data.tf`: Queries AWS AMI for latest Amazon Linux 2
- `variables.tf`: sg_id, subnets, ec2_names inputs
- `outputs.tf`: Exports instance IDs for ALB target groups

---

#### 4️⃣ **Application Load Balancer Module** (`modules/alb/`)
**Purpose:** Distributes traffic and provides high availability

**Key Features:**
- Application Load Balancer on port 80
- HTTP listener forwarding to target group
- Target group with health checks
- Automatic instance registration via target group attachments
- Health check configuration:
  - Path: `/` (root path)
  - Protocol: HTTP
  - Matcher: 200 (HTTP success)
  - Timeout: 5 seconds
  - Interval: 10 seconds
  - Healthy threshold: 2 checks
  - Unhealthy threshold: 3 checks

**Key Files:**
- `main.tf`: ALB, listeners, target groups, target group attachments
- `variables.tf`: VPC, subnets, security group, instance IDs
- `outputs.tf`: Exports ALB DNS name (for accessing infrastructure)

---

## 🚀 Deployment Guide

### Prerequisites

1. **AWS Account** with appropriate IAM permissions
2. **Terraform** installed (v1.0 or later)
   ```bash
   terraform --version
   ```
3. **AWS CLI** configured with credentials
   ```bash
   aws configure
   ```
4. **Git** for version control
5. **GitHub Repository** with Actions enabled

### Step 1: Clone Repository

```bash
git clone <your-github-repo-url>
cd vpc-terraform-github-actions
cd Terraform-VPC
```

### Step 2: Configure AWS Credentials

Option A - Environment Variables:
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

Option B - AWS CLI Profile:
```bash
aws configure
terraform init
```

### Step 3: Review Terraform Variables

Edit `terraform.tfvars` to customize (optional):
```hcl
vpc_cidr = "10.0.0.0/16"           # VPC network range
subnet_cidr = ["10.0.1.0/24", "10.0.2.0/24"]  # Subnet ranges
```

### Step 4: Initialize Terraform

```bash
terraform init
```

**What it does:**
- Downloads provider plugins (AWS provider)
- Creates `.terraform` directory
- Initializes backend for state management

### Step 5: Validate Configuration

```bash
terraform validate
```

**What it does:**
- Checks Terraform syntax
- Validates variable references
- Ensures module configuration is correct

### Step 6: Plan Deployment

```bash
terraform plan
```

**What it does:**
- Creates execution plan
- Shows ALL resources that will be created
- Displays estimated costs (resource counts)
- **Review this before applying!**

### Step 7: Apply Configuration

```bash
terraform apply
```

**When prompted:** Type `yes` to confirm deployment

**What it does:**
- Creates all AWS resources
- Outputs access information (ALB DNS name)
- Saves state file

### Step 8: Verify Deployment

After terraform apply completes (wait 3-5 minutes for instances to boot):

**1. Get ALB DNS Name:**
```bash
terraform output alb_dns_name
```

**2. Access via Browser:**
```
http://<alb-dns-name>
```

You should see the EC2 dashboard page.

**3. Check EC2 Instances:**
```bash
terraform output instances
```

**4. Verify Load Balancer Health:**
AWS Console → EC2 → Target Groups → Check "Health Status"

---

## 🔄 GitHub Actions CI/CD Pipeline

### Workflow File Location
`.github/workflows/deploy.yml`

### Pipeline Triggers
- Automatically triggered on `git push` to `main` branch
- Manual trigger via GitHub Actions UI

### Pipeline Stages

**Stage 1: Checkout Code**
- Pulls latest code from repository

**Stage 2: Setup Terraform**
- Downloads specified Terraform version
- Configures CLI

**Stage 3: Terraform Init**
- Initializes Terraform working directory
- Downloads AWS provider

**Stage 4: Terraform Validate**
- Checks syntax validity
- Validates module structure

**Stage 5: Terraform Plan**
- Creates execution plan
- Shows planned changes

**Stage 6: Terraform Apply**
- Deploys infrastructure to AWS
- Uses credentials from GitHub Secrets

### Setting Up CI/CD

#### 1. Store AWS Credentials in GitHub Secrets

Go to GitHub Repository → Settings → Secrets and Variables → Actions

Add these secrets:
- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
- `AWS_DEFAULT_REGION`: Region (e.g., us-east-1)

#### 2. Trigger Deployment

Push to main branch:
```bash
git add .
git commit -m "Deploy infrastructure"
git push origin main
```

Monitor deployment in GitHub Actions tab.

---

## 📊 Outputs & Access

After successful deployment, Terraform outputs:

```
alb_dns_name = "alb-dns-name-12345.us-east-1.elb.amazonaws.com"
alb_arn = "arn:aws:elasticloadbalancing:..."
alb_zone_id = "Z35SXDOTRQ7X7K"
instances = ["i-0123456789abcdef0", "i-0987654321fedcba0"]
sg_id = "sg-0123456789abcdef0"
subnet_ids = ["subnet-12345678", "subnet-87654321"]
vpc_id = "vpc-0123456789abcdef0"
```

### Access Infrastructure

**Web Dashboard:**
```
http://<alb_dns_name>
```

**Direct EC2 Access (via SSH):**
```bash
ssh -i your-key.pem ec2-user@<ec2-public-ip>
```



### Infrastructure as Code
- ✅ Terraform module design and best practices
- ✅ Variable abstraction and configuration management
- ✅ State management and outputs
- ✅ Resource dependencies and count meta-arguments

### AWS Cloud Services
- ✅ VPC design with multi-AZ deployment
- ✅ Security group configuration and network ACLs
- ✅ EC2 instance management with userdata scripts
- ✅ Application Load Balancer with health checks
- ✅ High availability and fault tolerance architecture

### DevOps & CI/CD
- ✅ GitHub Actions workflow automation
- ✅ Infrastructure deployment pipeline
- ✅ Automated testing (terraform validate)
- ✅ Version control with Git

### Cloud Architecture
- ✅ Network design (subnets, routing, IGW)
- ✅ Security best practices (security groups, public/private segmentation)
- ✅ Load balancing and auto-scaling patterns
- ✅ Cost optimization (t2.micro, free-tier resources)


---

*Answer:* "I built a production-ready AWS VPC infrastructure using Terraform that demonstrates full-stack DevOps capabilities. The architecture consists of:

1. **Networking**: Custom VPC (10.0.0.0/16) with 2 public subnets across availability zones
2. **Security**: Security group with HTTP, HTTPS, SSH ingress rules with proper CIDR restrictions
3. **Compute**: 2 EC2 instances (t2.micro, Amazon Linux 2) with Apache web server
4. **Load Balancing**: Application Load Balancer distributing traffic across instances with health checks
5. **Automation**: GitHub Actions CI/CD pipeline automatically deplying infrastructure on code push"



## 📝 Key Files Reference

| File | Purpose |
|------|---------|
| `Terraform-VPC/main.tf` | Module orchestration and variable passing |
| `Terraform-VPC/provider.tf` | AWS provider configuration |
| `Terraform-VPC/terraform.tfvars` | VPC and subnet CIDR configuration |
| `Terraform-VPC/outputs.tf` | Root-level outputs aggregating all resources |
| `modules/vpc/main.tf` | VPC, subnets, IGW, route tables |
| `modules/sg/main.tf` | Security group with ingress rules |
| `modules/ec2/main.tf` | EC2 instances with userdata |
| `modules/alb/main.tf` | Application load balancer setup |
| `.github/workflows/deploy.yml` | GitHub Actions CI/CD pipeline |

---

## 🔐 Security Considerations

### Production Recommendations

1. **SSH Access**: Restrict port 22 to specific IP addresses (not 0.0.0.0/0)
2. **State File**: Move from local state to S3 + DynamoDB for team collaboration
3. **Secrets**: Use AWS Secrets Manager for sensitive data instead of environment variables
4. **Private Subnets**: Place EC2 instances in private subnets with NAT Gateway for outbound access
5. **HTTPS**: Configure ALB with SSL/TLS certificates
6. **Network Segmentation**: Implement separate security groups for ALB and EC2
7. **Logging**: Enable VPC Flow Logs and ALB access logs

---

## 📚 Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Best_Practices.html)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform State Management](https://www.terraform.io/language/state)

---

## 📄 License

This project is provided as-is for educational and portfolio purposes.

---

---

## 👤 Author

**Abdur-S**

---

**Last Updated:** 2026
**Project Status:** ✅ Production Ready 
