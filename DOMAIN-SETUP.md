# Domain Setup Guide

## Overview

Access your GPT model via custom domain with HTTPS.

## Domains

- **API**: https://gpt.vmind.online
- **Web UI**: https://chat.gpt.vmind.online

## Prerequisites

1. Domain registered (vmind.online)
2. Route53 hosted zone exists
3. AWS ACM certificate

## Setup Steps

### Step 1: Verify Route53 Hosted Zone

```bash
aws route53 list-hosted-zones --query "HostedZones[?Name=='vmind.online.']"
```

If not exists, create:
```bash
aws route53 create-hosted-zone --name vmind.online --caller-reference $(date +%s)
```

### Step 2: Update Domain Registrar

Point nameservers to Route53:
```
ns-1234.awsdns-12.org
ns-5678.awsdns-34.com
ns-9012.awsdns-56.net
ns-3456.awsdns-78.co.uk
```

### Step 3: Deploy Infrastructure

```bash
cd terraform
terraform apply
```

This will:
- Create ACM certificate
- Validate via DNS
- Setup ALB with HTTPS
- Create Route53 records

### Step 4: Install AWS Load Balancer Controller

```bash
# Add Helm repo
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Install controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=red9inja-gpt-dev \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

### Step 5: Deploy Ingress

```bash
# Get certificate ARN
CERT_ARN=$(aws acm list-certificates --query "CertificateSummaryList[?DomainName=='gpt.vmind.online'].CertificateArn" --output text)

# Update ingress
sed -i "s|CERTIFICATE_ARN|$CERT_ARN|g" k8s/ingress.yaml

# Apply
kubectl apply -f k8s/ingress.yaml
```

### Step 6: Verify

```bash
# Check ingress
kubectl get ingress

# Get ALB URL
kubectl describe ingress red9inja-gpt-ingress
```

## Access

After DNS propagation (5-10 minutes):

- **API**: https://gpt.vmind.online/docs
- **Web UI**: https://chat.gpt.vmind.online

## Architecture

```
User → Route53 (gpt.vmind.online)
         ↓
     ALB (HTTPS)
         ↓
   Kubernetes Ingress
         ↓
   Service (red9inja-gpt-service)
         ↓
   Pods (GPU nodes)
```

## Subdomains

- `gpt.vmind.online` → API (port 8000)
- `chat.gpt.vmind.online` → Web UI (port 7860)

## SSL Certificate

- Auto-renewed by ACM
- Wildcard: *.gpt.vmind.online
- Validation: DNS (automatic)

## Troubleshooting

### Certificate pending validation

```bash
aws acm describe-certificate --certificate-arn CERT_ARN
```

Check Route53 records created.

### Domain not resolving

```bash
dig gpt.vmind.online
nslookup gpt.vmind.online
```

Wait for DNS propagation.

### Ingress not creating ALB

```bash
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

Check controller logs.

## Cost

- Route53 hosted zone: $0.50/month
- ACM certificate: Free
- ALB: ~$20/month

## Security

- HTTPS only (HTTP redirects to HTTPS)
- ACM managed certificates
- WAF can be added for protection
