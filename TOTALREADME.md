# 🚀 RED9INJA-GPT-INFRA - INFRASTRUCTURE OVERVIEW

## 📁 REPOSITORY STRUCTURE

```
├── terraform/                # Infrastructure as Code
│   ├── vpc.tf                # VPC, subnets, NAT gateways
│   ├── eks.tf                # EKS cluster + node groups
│   ├── cognito.tf            # User authentication
│   ├── dynamodb.tf           # Conversations + messages tables
│   ├── elasticache.tf        # Redis cluster
│   ├── sqs.tf                # Message queues
│   ├── s3.tf                 # File storage
│   ├── waf.tf                # Web Application Firewall
│   ├── secrets.tf            # Secrets Manager
│   ├── cloudfront.tf         # CDN
│   └── variables.tf          # Environment variables
│
├── k8s/                      # Kubernetes manifests
│   ├── deployment.yaml       # App deployment
│   ├── service.yaml          # LoadBalancer service
│   ├── hpa.yaml              # Auto-scaling
│   ├── configmap.yaml        # Configuration
│   ├── pvc.yaml              # Persistent storage
│   ├── monitoring.yaml       # Prometheus + Grafana
│   └── sonarqube.yaml        # SonarQube deployment
│
├── .github/workflows/        # CI/CD
│   ├── terraform-cicd.yml    # Multi-env deployment
│   ├── docker-build.yml      # Docker image build
│   ├── cloudflare-dns.yml    # DNS automation
│   ├── terraform-destroy.yml # Cleanup
│   ├── owasp-security.yml    # OWASP ZAP scan
│   └── trivy-security.yml    # IaC + secret scan
│
└── .zap/                     # Security scanning
    └── rules.tsv             # ZAP scanning rules
```

---

## 🏗️ AWS INFRASTRUCTURE

### Network Architecture
```
VPC (10.0.0.0/16)
├── Public Subnets (3 AZs)
│   ├── 10.0.1.0/24 (us-east-1a)
│   ├── 10.0.2.0/24 (us-east-1b)
│   └── 10.0.3.0/24 (us-east-1c)
│
├── Private Subnets (3 AZs)
│   ├── 10.0.11.0/24 (us-east-1a)
│   ├── 10.0.12.0/24 (us-east-1b)
│   └── 10.0.13.0/24 (us-east-1c)
│
├── Internet Gateway
├── NAT Gateways (3)
└── Route Tables
```

### EKS Cluster Configuration
```
EKS Cluster: red9inja-gpt-{env}
├── GPU Node Group
│   ├── Instance Type: g4dn.xlarge
│   ├── Min: 1, Max: 5, Desired: 2
│   └── Use: Model inference
│
└── CPU Node Group
    ├── Instance Type: t3.medium
    ├── Min: 1, Max: 10, Desired: 2
    └── Use: API services
```

### Storage Resources
```
DynamoDB Tables
├── conversations
│   ├── Partition Key: user_id
│   ├── Sort Key: conversation_id
│   └── Billing: PAY_PER_REQUEST
│
└── messages
    ├── Partition Key: conversation_id
    ├── Sort Key: message_id
    └── Billing: PAY_PER_REQUEST

ElastiCache Redis
├── Node Type: cache.t3.micro
├── Nodes: 1
└── Engine: Redis 7.0

S3 Buckets
├── red9inja-gpt-uploads-{env}
├── red9inja-gpt-models-{env}
└── red9inja-gpt-backups-{env}
```

### Security Resources
```
AWS Cognito
├── User Pool: red9inja-gpt-users-{env}
├── App Client: red9inja-gpt-client
└── Features: Email verification, MFA

AWS WAF
├── SQL Injection Rule
├── XSS Protection Rule
├── Rate Limiting Rule
└── Geo Blocking Rule

Secrets Manager
├── Database credentials
├── API keys
└── JWT secrets
```

---

## 🚦 CI/CD PIPELINES

### 1. Terraform CI/CD (`terraform-cicd.yml`)
**Trigger**: Push to dev/test/staging/prod branches  
**Steps**:
1. Checkout code
2. Setup Terraform
3. Terraform init
4. Terraform plan
5. Terraform apply (auto-approve)
6. Output infrastructure details

**Environments**:
- `dev`: Development environment
- `test`: Testing environment
- `staging`: Pre-production environment
- `prod`: Production environment

### 2. Docker Build (`docker-build.yml`)
**Trigger**: Push to dev/test/staging/prod branches  
**Steps**:
1. Build Docker image
2. Run Trivy security scan
3. Push to ECR
4. Deploy to EKS

### 3. Cloudflare DNS (`cloudflare-dns.yml`)
**Trigger**: After successful deployment  
**Steps**:
1. Get LoadBalancer IP
2. Create/Update DNS record
3. Verify DNS propagation

**Subdomains**:
- `dev.vmind.online` → Dev environment
- `test.vmind.online` → Test environment
- `staging.vmind.online` → Staging environment
- `gpt.vmind.online` → Production environment

### 4. Security Scans
**OWASP ZAP** (`owasp-security.yml`):
- Baseline security scan
- Runs on push + weekly schedule
- Scans live endpoints

**Trivy** (`trivy-security.yml`):
- IaC configuration scan
- Terraform misconfigurations
- Kubernetes manifest issues
- Secret detection
- Daily scheduled scans

### 5. Terraform Destroy (`terraform-destroy.yml`)
**Trigger**: Manual workflow dispatch  
**Purpose**: Clean up environment resources  
**Safety**: Requires manual confirmation

---

## 💰 COST OPTIMIZATION

### Multi-Environment Strategy

| Environment | Instance Type | Scaling | Auto-Shutdown | Monthly Cost |
|-------------|---------------|---------|---------------|--------------|
| Production  | ON_DEMAND     | 2-10    | No            | $689         |
| Staging     | ON_DEMAND     | 2-5     | No            | $210         |
| Test        | SPOT (70% off)| 1-3     | 8PM-8AM       | $84          |
| Dev         | SPOT (70% off)| 1-3     | 8PM-8AM       | $84          |

**Total**: $1,078/month (61% savings from $2,800)

### Cost Breakdown by Service

**Production Environment**:
- EKS Control Plane: $73/month
- GPU Nodes (2x g4dn.xlarge): $350/month
- CPU Nodes (2x t3.medium): $60/month
- DynamoDB: $50/month
- ElastiCache Redis: $50/month
- RDS PostgreSQL: $30/month
- S3 + CloudFront: $30/month
- NAT Gateway: $32/month
- Load Balancer: $14/month

**Optimization Techniques**:
1. SPOT instances for non-prod (70% savings)
2. Auto-shutdown for dev/test (50% time savings)
3. S3 Intelligent-Tiering
4. CloudFront caching (reduce origin requests)
5. DynamoDB on-demand pricing
6. Right-sized instance types

---

## 🔐 SECURITY ARCHITECTURE

### Defense in Depth

```
Layer 1: Cloudflare
├── DDoS Protection
├── SSL/TLS Termination
└── CDN Caching

Layer 2: AWS WAF
├── SQL Injection Prevention
├── XSS Protection
├── Rate Limiting
└── Geo Blocking

Layer 3: Network Security
├── VPC Isolation
├── Security Groups
├── NACLs
└── Private Subnets

Layer 4: Application Security
├── Cognito Authentication
├── JWT Token Validation
├── OWASP Middleware
└── Rate Limiting

Layer 5: Data Security
├── Encryption at Rest (DynamoDB, S3)
├── Encryption in Transit (TLS)
├── Secrets Manager
└── IAM Roles
```

### Security Scanning

**Static Analysis**:
- Trivy IaC scan (Terraform)
- Trivy secret detection
- SonarQube code analysis

**Dynamic Analysis**:
- OWASP ZAP baseline scan
- OWASP Dependency-Check

**Container Security**:
- Trivy image scan
- SBOM generation

---

## 📊 MONITORING & OBSERVABILITY

### Prometheus Metrics
```yaml
Collected Metrics:
- api_requests_total
- api_request_duration_seconds
- generation_tokens_total
- cache_hits_total
- cache_misses_total
- rate_limit_exceeded_total
- active_connections
- queue_depth
```

### Grafana Dashboards
```
Dashboard 1: API Performance
├── Request rate
├── Response time (p50, p95, p99)
├── Error rate
└── Throughput

Dashboard 2: Infrastructure
├── CPU usage
├── Memory usage
├── Disk I/O
└── Network traffic

Dashboard 3: Business Metrics
├── Active users
├── Conversations created
├── Tokens generated
└── Cache hit rate
```

### CloudWatch Alarms
```
Critical Alarms:
- CPU > 80% for 5 minutes
- Memory > 85% for 5 minutes
- Error rate > 5% for 2 minutes
- Response time > 1s (p95)

Warning Alarms:
- Disk usage > 70%
- Cache hit rate < 60%
- Queue depth > 1000
```

---

## 🚀 DEPLOYMENT GUIDE

### Prerequisites
```bash
# Required tools
- AWS CLI v2
- Terraform v1.5+
- kubectl v1.27+
- Docker v20+
- Git
```

### Initial Setup

1. **Configure AWS Credentials**
```bash
aws configure
# Enter AWS Access Key ID
# Enter AWS Secret Access Key
# Default region: us-east-1
```

2. **Set GitHub Secrets**
Navigate to: Settings → Secrets and variables → Actions

Required secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION` (us-east-1)
- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ZONE_ID`

3. **Deploy Infrastructure**
```bash
# Clone repository
git clone https://github.com/red9inja/red9inja-GPT-INFRA.git
cd red9inja-GPT-INFRA

# Create and push to environment branch
git checkout -b dev
git push origin dev

# GitHub Actions will automatically:
# 1. Run Terraform plan
# 2. Apply infrastructure changes
# 3. Configure EKS cluster
# 4. Deploy Kubernetes resources
# 5. Update Cloudflare DNS
```

4. **Verify Deployment**
```bash
# Check EKS cluster
aws eks list-clusters

# Get kubeconfig
aws eks update-kubeconfig --name red9inja-gpt-dev --region us-east-1

# Check pods
kubectl get pods -n default

# Check services
kubectl get svc -n default
```

### Environment Promotion

```bash
# Dev → Test
git checkout test
git merge dev
git push origin test

# Test → Staging
git checkout staging
git merge test
git push origin staging

# Staging → Prod
git checkout prod
git merge staging
git push origin prod
```

---

## 🔧 TROUBLESHOOTING

### Common Issues

**Issue**: Terraform apply fails
```bash
# Solution: Check AWS credentials
aws sts get-caller-identity

# Verify Terraform state
terraform state list
```

**Issue**: EKS pods not starting
```bash
# Check pod status
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>

# Check node resources
kubectl top nodes
```

**Issue**: DNS not resolving
```bash
# Verify Cloudflare DNS
dig dev.vmind.online

# Check LoadBalancer
kubectl get svc
```

**Issue**: High costs
```bash
# Check running resources
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"

# Review Cost Explorer
aws ce get-cost-and-usage --time-period Start=2026-02-01,End=2026-02-08
```

---

## 📝 TERRAFORM MODULES

### VPC Module
- Creates VPC with public/private subnets
- Configures NAT gateways
- Sets up route tables

### EKS Module
- Creates EKS cluster
- Configures node groups (GPU + CPU)
- Sets up IAM roles

### Security Module
- Configures Cognito user pool
- Sets up WAF rules
- Creates security groups

### Storage Module
- Creates DynamoDB tables
- Sets up ElastiCache Redis
- Configures S3 buckets

---

## 🎯 BEST PRACTICES

1. **Always use environment branches** (never push to main)
2. **Review Terraform plan** before applying
3. **Monitor costs** regularly in AWS Cost Explorer
4. **Keep secrets in AWS Secrets Manager** (never in code)
5. **Use SPOT instances** for non-production
6. **Enable auto-shutdown** for dev/test environments
7. **Regular security scans** (Trivy, OWASP)
8. **Backup DynamoDB tables** regularly
9. **Use CloudFront** for static content
10. **Monitor Grafana dashboards** daily

---

## 📞 SUPPORT

**Issues**: https://github.com/red9inja/red9inja-GPT-INFRA/issues  
**Application Repo**: https://github.com/red9inja/red9inja-GPT  
**Documentation**: See TOTALREADME.md in application repo

---

**Built with ❤️ by red9inja**
