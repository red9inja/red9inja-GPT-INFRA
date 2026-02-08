# red9inja-GPT-INFRA

Complete Terraform infrastructure with GitHub Actions CI/CD to deploy red9inja-GPT on AWS EKS.

## Features

- Automated CI/CD with GitHub Actions
- Multi-environment support (dev, test, staging, prod)
- EKS Cluster with GPU nodes
- Auto-scaling and load balancing
- Docker image build and push to ECR
- Infrastructure as Code with Terraform

## Quick Start

### 1. Setup GitHub Secrets

Add to repository secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### 2. Create S3 Bucket for Terraform State

```bash
aws s3 mb s3://red9inja-terraform-state --region us-east-1
```

### 3. Create and Push to Branch

```bash
git checkout -b dev
git push origin dev
```

GitHub Actions will automatically:
- Create EKS cluster
- Build Docker image
- Deploy application
- Expose via Load Balancer

## CI/CD Pipeline

### Automated Deployment Flow

```
Push to Branch → GitHub Actions → Terraform Apply → Build Docker → Push to ECR → Deploy to EKS
```

Branches:
- `dev` → dev environment
- `test` → test environment
- `staging` → staging environment
- `prod` → production environment

### Workflows

1. **terraform-cicd.yml** - Main deployment pipeline
2. **docker-build.yml** - Build and push Docker images
3. **terraform-destroy.yml** - Manual cleanup

## Architecture

```
Internet
    |
    v
Application Load Balancer
    |
    v
EKS Cluster
    |
    +-- GPU Node Group (for model inference)
    +-- CPU Node Group (for API/web)
    |
    v
ECR (Container Registry)
```

## Prerequisites

- AWS Account with appropriate permissions
- AWS CLI configured
- Terraform >= 1.0
- kubectl
- Docker

## Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/red9inja/red9inja-GPT-INFRA.git
cd red9inja-GPT-INFRA
```

### 2. Configure Variables

Edit `terraform.tfvars`:

```hcl
aws_region = "us-east-1"
cluster_name = "red9inja-gpt-cluster"
environment = "production"
```

### 3. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply infrastructure
terraform apply
```

### 4. Configure kubectl

```bash
aws eks update-kubeconfig --region us-east-1 --name red9inja-gpt-cluster
```

### 5. Deploy Application

```bash
# Build and push Docker image
./scripts/build-and-push.sh

# Deploy to Kubernetes
kubectl apply -f k8s/
```

## Project Structure

```
red9inja-GPT-INFRA/
├── terraform/
│   ├── main.tf              # Main Terraform configuration
│   ├── vpc.tf               # VPC and networking
│   ├── eks.tf               # EKS cluster configuration
│   ├── ecr.tf               # Container registry
│   ├── iam.tf               # IAM roles and policies
│   ├── security-groups.tf   # Security groups
│   ├── variables.tf         # Input variables
│   ├── outputs.tf           # Output values
│   └── versions.tf          # Provider versions
├── k8s/
│   ├── deployment.yaml      # Kubernetes deployment
│   ├── service.yaml         # Kubernetes service
│   ├── ingress.yaml         # Ingress configuration
│   ├── hpa.yaml             # Horizontal Pod Autoscaler
│   └── configmap.yaml       # Configuration
├── docker/
│   ├── Dockerfile           # Container image
│   └── .dockerignore        # Docker ignore
├── scripts/
│   ├── build-and-push.sh    # Build and push image
│   ├── deploy.sh            # Deploy to EKS
│   └── destroy.sh           # Cleanup resources
├── terraform.tfvars         # Terraform variables
└── README.md                # This file
```

## Infrastructure Components

### VPC
- CIDR: 10.0.0.0/16
- 3 Public subnets
- 3 Private subnets
- NAT Gateways
- Internet Gateway

### EKS Cluster
- Kubernetes version: 1.28
- GPU node group (g4dn.xlarge) for inference
- CPU node group (t3.large) for API
- Auto-scaling enabled

### ECR
- Private repository for Docker images
- Lifecycle policies for image cleanup

### Security
- Security groups with minimal required access
- IAM roles with least privilege
- Private subnets for worker nodes

## Configuration

### Terraform Variables

| Variable | Description | Default |
|----------|-------------|---------|
| aws_region | AWS region | us-east-1 |
| cluster_name | EKS cluster name | red9inja-gpt-cluster |
| environment | Environment name | production |
| vpc_cidr | VPC CIDR block | 10.0.0.0/16 |
| gpu_instance_type | GPU instance type | g4dn.xlarge |
| gpu_desired_size | GPU nodes desired | 1 |
| gpu_min_size | GPU nodes minimum | 1 |
| gpu_max_size | GPU nodes maximum | 3 |

### Kubernetes Resources

- Deployment: Manages GPT model pods
- Service: Exposes API endpoints
- Ingress: Routes external traffic
- HPA: Auto-scales based on CPU/GPU usage
- ConfigMap: Application configuration

## Deployment

### Build Docker Image

```bash
cd docker
docker build -t red9inja-gpt:latest .
```

### Push to ECR

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com
docker tag red9inja-gpt:latest ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/red9inja-gpt:latest
docker push ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/red9inja-gpt:latest
```

### Deploy to Kubernetes

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
```

## Monitoring

### Check Cluster Status

```bash
kubectl get nodes
kubectl get pods
kubectl get services
```

### View Logs

```bash
kubectl logs -f deployment/red9inja-gpt
```

### Metrics

```bash
kubectl top nodes
kubectl top pods
```

## Scaling

### Manual Scaling

```bash
kubectl scale deployment red9inja-gpt --replicas=3
```

### Auto-scaling

HPA automatically scales based on:
- CPU utilization > 70%
- GPU utilization > 80%
- Request rate

## Cost Estimation

### Monthly Costs (Approximate)

| Resource | Cost |
|----------|------|
| EKS Cluster | $73 |
| GPU Nodes (1x g4dn.xlarge) | $380 |
| CPU Nodes (2x t3.large) | $120 |
| Load Balancer | $20 |
| NAT Gateway | $45 |
| Data Transfer | $50 |
| Total | ~$688/month |

## Cleanup

### Destroy Infrastructure

```bash
# Delete Kubernetes resources
kubectl delete -f k8s/

# Destroy Terraform infrastructure
terraform destroy
```

## Security Best Practices

- Use private subnets for worker nodes
- Enable encryption at rest
- Use IAM roles for service accounts
- Implement network policies
- Enable audit logging
- Use secrets management

## Troubleshooting

### Pods not starting

```bash
kubectl describe pod POD_NAME
kubectl logs POD_NAME
```

### Node issues

```bash
kubectl describe node NODE_NAME
```

### EKS cluster issues

```bash
aws eks describe-cluster --name red9inja-gpt-cluster
```

## Contributing

Contributions welcome! Please submit pull requests.

## License

MIT License

## Support

For issues, please open a GitHub issue.
