# red9inja-GPT-INFRA - Infrastructure Overview

## Project Description

Complete Infrastructure as Code (IaC) using Terraform to provision and manage AWS resources for red9inja-GPT application with automated CI/CD pipelines.

## Infrastructure Architecture

```
GITHUB REPOSITORY
  |
  v
GITHUB ACTIONS (CI/CD Pipeline)
  |
  +-- Terraform Workflow
  |     |
  |     v
  |   AWS RESOURCES PROVISIONING
  |     |
  |     +-- VPC & NETWORKING
  |     |     |
  |     |     +-- VPC (10.0.0.0/16)
  |     |     +-- Public Subnets (3 AZs)
  |     |     +-- Private Subnets (3 AZs)
  |     |     +-- NAT Gateways
  |     |     +-- Internet Gateway
  |     |     +-- Route Tables
  |     |     +-- Security Groups
  |     |
  |     +-- EKS CLUSTER
  |     |     |
  |     |     +-- Control Plane
  |     |     +-- GPU Node Group (g4dn.xlarge)
  |     |     |     - SPOT for dev/test/staging
  |     |     |     - ON_DEMAND for prod
  |     |     +-- CPU Node Group (t3.large)
  |     |     |     - SPOT for dev/test/staging
  |     |     |     - ON_DEMAND for prod
  |     |     +-- Auto Scaling
  |     |     +-- NVIDIA Device Plugin
  |     |
  |     +-- AUTHENTICATION
  |     |     |
  |     |     +-- Cognito User Pool
  |     |     +-- App Client
  |     |     +-- User Groups (admin, users, premium)
  |     |     +-- Hosted UI Domain
  |     |
  |     +-- DATABASE
  |     |     |
  |     |     +-- DynamoDB Tables
  |     |     |     - Conversations Table
  |     |     |     - Messages Table
  |     |     +-- Global Secondary Indexes
  |     |     +-- Point-in-time Recovery
  |     |     +-- TTL Configuration
  |     |
  |     +-- CACHING
  |     |     |
  |     |     +-- ElastiCache Redis
  |     |     +-- 2-node Cluster
  |     |     +-- Multi-AZ
  |     |     +-- Automatic Failover
  |     |     +-- Encryption (at rest & transit)
  |     |
  |     +-- QUEUE
  |     |     |
  |     |     +-- SQS Queue (Main)
  |     |     +-- SQS Dead Letter Queue
  |     |     +-- Message Retention (24 hours)
  |     |
  |     +-- STORAGE
  |     |     |
  |     |     +-- S3 Bucket (Model Checkpoints)
  |     |     +-- Versioning Enabled
  |     |     +-- Lifecycle Policies
  |     |     +-- CloudFront Distribution (CDN)
  |     |
  |     +-- SECURITY
  |     |     |
  |     |     +-- AWS WAF
  |     |     |     - Rate Limiting Rules
  |     |     |     - SQL Injection Protection
  |     |     |     - XSS Protection
  |     |     +-- Secrets Manager
  |     |     |     - Application Secrets
  |     |     |     - Auto Rotation
  |     |     +-- IAM Roles & Policies
  |     |
  |     +-- CONTAINER REGISTRY
  |     |     |
  |     |     +-- ECR Repository
  |     |     +-- Image Scanning
  |     |     +-- Lifecycle Policies
  |     |
  |     +-- COST OPTIMIZATION
  |           |
  |           +-- Auto-Shutdown Lambda (dev/test)
  |           +-- EventBridge Rules
  |           |     - Shutdown at 8 PM
  |           |     - Startup at 8 AM
  |           +-- Spot Instances (non-prod)
  |
  +-- Docker Build Workflow
  |     |
  |     v
  |   BUILD & PUSH IMAGE
  |     |
  |     +-- Clone red9inja-GPT code
  |     +-- Build Docker image
  |     +-- Tag with environment
  |     +-- Push to ECR
  |     +-- Update Kubernetes deployment
  |
  +-- Cloudflare DNS Workflow
        |
        v
      UPDATE DNS
        |
        +-- Get Load Balancer DNS
        +-- Create CNAME in Cloudflare
        |     - dev.vmind.online
        |     - test.vmind.online
        |     - staging.vmind.online
        |     - gpt.vmind.online
        +-- Enable Proxy (Orange Cloud)
        +-- Enable Security Features
              - Always Use HTTPS
              - SSL Full
              - Bot Fight Mode
              - Browser Integrity Check
```

## Complete Deployment Flow

```
STEP 1: DEVELOPER ACTION
Developer --> Push code to branch (dev/test/staging/prod)
          --> NOT main branch

STEP 2: TRIGGER DETECTION
GitHub Actions --> Detect push to environment branch
              --> Start terraform-cicd.yml workflow

STEP 3: TERRAFORM INITIALIZATION
Workflow --> terraform init
         --> Download providers (AWS, Kubernetes)
         --> Configure S3 backend

STEP 4: TERRAFORM VALIDATION
Workflow --> terraform fmt -check
         --> terraform validate
         --> Check syntax and configuration

STEP 5: TERRAFORM PLANNING
Workflow --> terraform plan
         --> Calculate resource changes
         --> Show what will be created/updated/deleted

STEP 6: TERRAFORM APPLY
Workflow --> terraform apply -auto-approve
         --> Create/Update AWS resources
         --> Wait for completion (15-20 minutes)

STEP 7: RESOURCE CREATION ORDER
Terraform --> 1. VPC & Networking
          --> 2. Security Groups
          --> 3. IAM Roles
          --> 4. EKS Cluster
          --> 5. Node Groups
          --> 6. Cognito
          --> 7. DynamoDB
          --> 8. Redis
          --> 9. SQS
          --> 10. S3 & CloudFront
          --> 11. WAF
          --> 12. Secrets Manager
          --> 13. ECR

STEP 8: KUBERNETES CONFIGURATION
Workflow --> aws eks update-kubeconfig
         --> Configure kubectl access
         --> Verify cluster connection

STEP 9: APPLICATION DEPLOYMENT
Workflow --> kubectl apply -f k8s/configmap.yaml
         --> kubectl apply -f k8s/pvc.yaml
         --> kubectl apply -f k8s/deployment.yaml
         --> kubectl apply -f k8s/service.yaml
         --> kubectl apply -f k8s/hpa.yaml
         --> kubectl apply -f k8s/monitoring.yaml

STEP 10: WAIT FOR LOAD BALANCER
Workflow --> kubectl get service
         --> Wait for EXTERNAL-IP
         --> Get ALB DNS name

STEP 11: DNS UPDATE (Cloudflare)
cloudflare-dns.yml --> Trigger after terraform completes
                   --> Get ALB hostname
                   --> Call Cloudflare API
                   --> Create/Update CNAME record
                   --> Enable security features

STEP 12: VERIFICATION
Workflow --> Check /health endpoint
         --> Verify Prometheus metrics
         --> Check Grafana dashboard
         --> Validate DNS resolution

STEP 13: NOTIFICATION
Workflow --> Success/Failure status
         --> Deployment logs
         --> Resource URLs
```

## Repository Structure

```
red9inja-GPT-INFRA/
├── .github/
│   └── workflows/
│       ├── terraform-cicd.yml      # Main deployment pipeline
│       ├── docker-build.yml        # Docker image build
│       ├── cloudflare-dns.yml      # DNS automation
│       └── terraform-destroy.yml   # Cleanup workflow
│
├── terraform/
│   ├── versions.tf                 # Provider versions
│   ├── variables.tf                # Input variables
│   ├── vpc.tf                      # VPC & networking
│   ├── eks.tf                      # EKS cluster
│   ├── cognito.tf                  # User authentication
│   ├── dynamodb.tf                 # Database tables
│   ├── redis.tf                    # Caching layer
│   ├── sqs.tf                      # Message queue
│   ├── s3-cdn.tf                   # Storage & CDN
│   ├── waf.tf                      # Web firewall
│   ├── secrets.tf                  # Secrets management
│   ├── ecr.tf                      # Container registry
│   ├── auto-shutdown.tf            # Cost optimization
│   └── outputs.tf                  # Output values
│
├── k8s/
│   ├── deployment.yaml             # Application deployment
│   ├── service.yaml                # Load balancer service
│   ├── hpa.yaml                    # Auto-scaling
│   ├── configmap.yaml              # Configuration
│   ├── pvc.yaml                    # Persistent storage
│   └── monitoring.yaml             # Prometheus & Grafana
│
├── docker/
│   ├── Dockerfile                  # Container image
│   └── .dockerignore               # Build exclusions
│
├── scripts/
│   ├── build-and-push.sh           # Manual build script
│   ├── deploy.sh                   # Manual deploy script
│   └── destroy.sh                  # Cleanup script
│
├── terraform.tfvars                # Configuration values
├── .gitignore                      # Git exclusions
└── README.md                       # This file
```

## AWS Resources Created

### Networking (VPC)
- 1 VPC (10.0.0.0/16)
- 3 Public Subnets
- 3 Private Subnets
- 3 NAT Gateways (or 1 if single_nat_gateway=true)
- 1 Internet Gateway
- Route Tables
- Security Groups

### Compute (EKS)
- 1 EKS Cluster
- 1 GPU Node Group (1-3 nodes)
- 1 CPU Node Group (2-5 nodes)
- Auto Scaling Groups
- Launch Templates

### Authentication (Cognito)
- 1 User Pool
- 1 App Client
- 3 User Groups (admin, users, premium)
- 1 Hosted UI Domain

### Database (DynamoDB)
- 1 Conversations Table
- 1 Messages Table
- 2 Global Secondary Indexes
- Point-in-time Recovery
- TTL Configuration

### Caching (ElastiCache)
- 1 Redis Replication Group
- 2 Cache Nodes
- 1 Subnet Group
- Security Group

### Queue (SQS)
- 1 Main Queue
- 1 Dead Letter Queue

### Storage (S3)
- 1 S3 Bucket
- Versioning
- Lifecycle Policies
- 1 CloudFront Distribution
- Origin Access Identity

### Security
- 1 WAF Web ACL
- 4 WAF Rules
- 1 Secrets Manager Secret
- IAM Roles & Policies

### Container (ECR)
- 1 ECR Repository
- Image Scanning
- Lifecycle Policy

### Cost Optimization
- 1 Lambda Function (auto-shutdown)
- 2 EventBridge Rules (shutdown/startup)
- IAM Role for Lambda

## Terraform Variables

### Required Variables
```hcl
aws_region           = "us-east-1"
cluster_name         = "red9inja-gpt-dev"
environment          = "dev"
```

### Optional Variables
```hcl
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
kubernetes_version   = "1.28"

gpu_instance_type    = "g4dn.xlarge"
gpu_desired_size     = 1
gpu_min_size         = 1
gpu_max_size         = 3

cpu_instance_type    = "t3.large"
cpu_desired_size     = 2
cpu_min_size         = 2
cpu_max_size         = 5

enable_nat_gateway   = true
single_nat_gateway   = false
```

## GitHub Secrets Required

### AWS Credentials
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY

### Cloudflare
- CLOUDFLARE_API_TOKEN

### Cross-Repo (in red9inja-GPT)
- INFRA_TRIGGER_TOKEN (GitHub PAT)

## Branch Strategy

```
main
  |
  +-- dev (auto-deploy to dev environment)
  |     - Spot instances
  |     - Auto-shutdown enabled
  |     - dev.vmind.online
  |
  +-- test (auto-deploy to test environment)
  |     - Spot instances
  |     - Auto-shutdown enabled
  |     - test.vmind.online
  |
  +-- staging (auto-deploy to staging environment)
  |     - Spot instances
  |     - No auto-shutdown
  |     - staging.vmind.online
  |
  +-- prod (auto-deploy to production)
        - On-demand instances
        - No auto-shutdown
        - gpt.vmind.online
```

## Cost Optimization Features

### 1. Spot Instances
- Enabled for: dev, test, staging
- Disabled for: prod
- Savings: 70% on compute costs

### 2. Auto-Shutdown
- Enabled for: dev, test
- Schedule: 8 PM - 8 AM daily
- Savings: 60% on dev/test costs

### 3. Single NAT Gateway
- Option to use 1 NAT instead of 3
- Savings: $90/month

### 4. S3 Lifecycle
- Transition to Glacier after 90 days
- Delete old versions after 30 days
- Savings: 80% on storage

## Monitoring & Outputs

### Terraform Outputs
```bash
terraform output cluster_name
terraform output cluster_endpoint
terraform output ecr_repository_url
terraform output cognito_user_pool_id
terraform output redis_endpoint
terraform output sqs_queue_url
```

### Kubernetes Resources
```bash
kubectl get nodes
kubectl get pods
kubectl get services
kubectl get hpa
```

### Monitoring URLs
- Prometheus: http://prometheus-service:9090
- Grafana: http://grafana-lb-url
- API Docs: https://gpt.vmind.online/docs

## Security Features

### Network Security
- Private subnets for worker nodes
- Security groups with minimal access
- No public IPs on worker nodes

### Application Security
- WAF with managed rule sets
- Rate limiting (2000 req/5min per IP)
- SQL injection protection
- XSS protection

### Data Security
- Encryption at rest (DynamoDB, Redis, S3)
- Encryption in transit (TLS/SSL)
- Secrets in Secrets Manager
- No hardcoded credentials

### Access Control
- IAM roles with least privilege
- Cognito for user authentication
- Role-based access control
- MFA support

## Disaster Recovery

### Backup Strategy
- DynamoDB: Point-in-time recovery (35 days)
- Redis: Daily snapshots (5 days)
- S3: Versioning enabled
- EBS: Automated snapshots

### Recovery Procedures
1. Database: Restore from point-in-time
2. Cache: Rebuild from database
3. Application: Redeploy from ECR
4. Infrastructure: terraform apply

### RTO/RPO
- Recovery Time Objective: 30 minutes
- Recovery Point Objective: 5 minutes

## Troubleshooting

### Terraform Errors
```bash
# State lock issues
terraform force-unlock LOCK_ID

# State refresh
terraform refresh

# Import existing resources
terraform import aws_eks_cluster.main cluster-name
```

### EKS Issues
```bash
# Update kubeconfig
aws eks update-kubeconfig --name cluster-name

# Check cluster status
aws eks describe-cluster --name cluster-name

# View node logs
kubectl logs -n kube-system -l app=aws-node
```

### Deployment Failures
```bash
# Check pod status
kubectl describe pod POD_NAME

# View logs
kubectl logs POD_NAME

# Check events
kubectl get events --sort-by='.lastTimestamp'
```

## Manual Operations

### Deploy Infrastructure
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Build and Push Image
```bash
./scripts/build-and-push.sh
```

### Deploy Application
```bash
./scripts/deploy.sh
```

### Destroy Everything
```bash
./scripts/destroy.sh
```

## CI/CD Pipeline Triggers

### Automatic Triggers
- Push to dev/test/staging/prod branches
- Changes in terraform/ or k8s/ directories
- Triggered by red9inja-GPT repo (via repository_dispatch)

### Manual Triggers
- GitHub Actions UI (workflow_dispatch)
- Select environment
- Click "Run workflow"

## Performance Tuning

### EKS Optimization
- Use larger instance types for production
- Enable cluster autoscaler
- Configure pod resource limits
- Use HPA for auto-scaling

### Database Optimization
- Use on-demand billing for variable load
- Enable auto-scaling for DynamoDB
- Use GSI for query optimization
- Implement caching strategy

### Network Optimization
- Use VPC endpoints for AWS services
- Enable VPC flow logs for debugging
- Optimize security group rules
- Use private subnets for databases

## Compliance & Governance

### Tagging Strategy
All resources tagged with:
- Project: red9inja-GPT
- Environment: dev/test/staging/prod
- ManagedBy: Terraform
- Owner: red9inja

### Cost Allocation
- Tags enable cost tracking per environment
- CloudWatch billing alarms
- Budget alerts configured

### Audit Logging
- CloudTrail enabled
- VPC Flow Logs
- EKS audit logs
- WAF logs

## Related Documentation

- Application Code: red9inja-GPT/JUSTREADME.md
- Authentication: red9inja-GPT/AUTHENTICATION.md
- Conversations: red9inja-GPT/CONVERSATIONS.md
- Production Scale: red9inja-GPT/PRODUCTION-SCALE.md
- Advanced Features: red9inja-GPT/ADVANCED-FEATURES.md
- Complete Features: red9inja-GPT/COMPLETE-FEATURES.md

## Support

For infrastructure issues:
- GitHub Issues: https://github.com/red9inja/red9inja-GPT-INFRA/issues
- Check CloudWatch logs
- Review Terraform state
- Verify AWS console

## License

MIT License
