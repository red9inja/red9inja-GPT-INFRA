# Quick Start Guide

## Prerequisites

1. AWS CLI configured with credentials
2. Terraform installed
3. kubectl installed
4. Docker installed

## Step-by-Step Deployment

### 1. Clone Repository

```bash
git clone https://github.com/red9inja/red9inja-GPT-INFRA.git
cd red9inja-GPT-INFRA
```

### 2. Initialize Terraform

```bash
cd terraform
terraform init
```

### 3. Review and Apply Infrastructure

```bash
terraform plan
terraform apply
```

This will create:
- VPC with public and private subnets
- EKS cluster with GPU and CPU node groups
- ECR repository
- Security groups and IAM roles

Wait 15-20 minutes for completion.

### 4. Configure kubectl

```bash
aws eks update-kubeconfig --region us-east-1 --name red9inja-gpt-cluster
kubectl get nodes
```

### 5. Build and Push Docker Image

```bash
cd ..
./scripts/build-and-push.sh
```

### 6. Deploy Application

```bash
./scripts/deploy.sh
```

### 7. Get Service Endpoint

```bash
kubectl get service red9inja-gpt-service
```

Copy the EXTERNAL-IP and access:
- API: http://EXTERNAL-IP/docs
- Web UI: http://EXTERNAL-IP:7860

## Verify Deployment

```bash
kubectl get pods
kubectl get services
kubectl logs -f deployment/red9inja-gpt
```

## Scale Application

```bash
kubectl scale deployment red9inja-gpt --replicas=2
```

## Cleanup

```bash
./scripts/destroy.sh
```

## Troubleshooting

### Pods not starting
```bash
kubectl describe pod POD_NAME
kubectl logs POD_NAME
```

### Check node status
```bash
kubectl get nodes
kubectl describe node NODE_NAME
```

### Check GPU availability
```bash
kubectl get nodes -o json | jq '.items[].status.allocatable'
```
