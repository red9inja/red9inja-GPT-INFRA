# GitHub Actions CI/CD Setup Guide

## Overview

This repository uses GitHub Actions to automatically deploy infrastructure to AWS EKS based on branch names:

- `dev` branch → dev environment
- `test` branch → test environment
- `staging` branch → staging environment
- `prod` branch → production environment

## Prerequisites

1. AWS Account with appropriate permissions
2. GitHub repository with Actions enabled
3. AWS credentials (Access Key ID and Secret Access Key)

## Setup Instructions

### Step 1: Create GitHub Secrets

Go to your repository: Settings → Secrets and variables → Actions → New repository secret

Add these secrets:

1. `AWS_ACCESS_KEY_ID`
   - Your AWS access key ID
   
2. `AWS_SECRET_ACCESS_KEY`
   - Your AWS secret access key

### Step 2: Create S3 Bucket for Terraform State

```bash
aws s3 mb s3://red9inja-terraform-state --region us-east-1
aws s3api put-bucket-versioning \
  --bucket red9inja-terraform-state \
  --versioning-configuration Status=Enabled
```

### Step 3: Create Branches

```bash
git checkout -b dev
git push origin dev

git checkout -b test
git push origin test

git checkout -b staging
git push origin staging

git checkout -b prod
git push origin prod
```

### Step 4: Push to Trigger Deployment

```bash
git checkout dev
git add .
git commit -m "Deploy to dev"
git push origin dev
```

This will automatically:
1. Run Terraform to create infrastructure
2. Build Docker image
3. Push to ECR
4. Deploy to EKS
5. Expose via Load Balancer

## Workflows

### 1. Terraform CI/CD (terraform-cicd.yml)

Triggers on push to: dev, test, staging, prod

Steps:
- Checkout code
- Configure AWS credentials
- Setup Terraform
- Terraform init, validate, plan
- Terraform apply (on push)
- Deploy to Kubernetes
- Get service endpoint

### 2. Docker Build (docker-build.yml)

Triggers on push to docker/ directory

Steps:
- Build Docker image
- Push to ECR
- Update Kubernetes deployment
- Rolling update

### 3. Terraform Destroy (terraform-destroy.yml)

Manual trigger only (workflow_dispatch)

Steps:
- Select environment
- Type "destroy" to confirm
- Delete Kubernetes resources
- Destroy Terraform infrastructure

## Branch Strategy

```
main (protected)
  ├── dev (auto-deploy)
  ├── test (auto-deploy)
  ├── staging (auto-deploy)
  └── prod (auto-deploy, requires approval)
```

## Environment Configuration

Each environment gets:
- Separate EKS cluster: `red9inja-gpt-{env}`
- Separate VPC
- Separate ECR tags
- Environment-specific variables

## Deployment Flow

```
Push to branch → GitHub Actions triggered
                      ↓
              Terraform Plan & Apply
                      ↓
              Build Docker Image
                      ↓
              Push to ECR
                      ↓
              Deploy to EKS
                      ↓
              Service Available
```

## Monitoring Deployments

### View Workflow Runs

Go to: Actions tab in GitHub repository

### Check Logs

Click on workflow run → Click on job → View logs

### Get Service Endpoint

After deployment completes, check workflow logs for:
```
kubectl get service red9inja-gpt-service
```

## Manual Operations

### Destroy Environment

1. Go to Actions tab
2. Select "Terraform Destroy" workflow
3. Click "Run workflow"
4. Select environment
5. Type "destroy"
6. Click "Run workflow"

### Scale Deployment

```bash
aws eks update-kubeconfig --region us-east-1 --name red9inja-gpt-dev
kubectl scale deployment red9inja-gpt --replicas=3
```

### View Logs

```bash
kubectl logs -f deployment/red9inja-gpt
```

## Cost Management

Each environment costs ~$688/month:
- Dev: For development and testing
- Test: For QA testing
- Staging: Pre-production testing
- Prod: Production workload

Total: ~$2,752/month for all environments

## Security Best Practices

1. Use separate AWS accounts for each environment
2. Enable branch protection for prod
3. Require pull request reviews
4. Use AWS IAM roles instead of access keys (recommended)
5. Enable CloudTrail logging
6. Use AWS Secrets Manager for sensitive data

## Troubleshooting

### Workflow fails at Terraform Apply

Check:
- AWS credentials are correct
- S3 bucket exists
- IAM permissions are sufficient

### Deployment fails

Check:
- ECR repository exists
- Docker image built successfully
- Kubernetes manifests are valid

### Service not accessible

Check:
- Load balancer is created
- Security groups allow traffic
- Pods are running

## Advanced Configuration

### Add Environment Variables

Edit `.github/workflows/terraform-cicd.yml`:

```yaml
- name: Terraform Apply
  env:
    TF_VAR_custom_variable: value
```

### Change Instance Types

Edit `terraform.tfvars` per branch:

```hcl
gpu_instance_type = "g4dn.2xlarge"  # Larger GPU
cpu_instance_type = "t3.xlarge"     # More CPU
```

### Enable Auto-scaling

Already configured in `k8s/hpa.yaml`

Modify limits:
```yaml
minReplicas: 2
maxReplicas: 10
```

## Support

For issues:
1. Check workflow logs
2. Check AWS CloudWatch logs
3. Open GitHub issue
