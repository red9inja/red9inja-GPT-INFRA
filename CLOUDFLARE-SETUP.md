# Cloudflare DNS Automation Setup

## Overview

Automatically creates subdomain in Cloudflare based on deployment branch:

- `dev` branch → `dev.vmind.online`
- `test` branch → `test.vmind.online`
- `staging` branch → `staging.vmind.online`
- `prod` branch → `gpt.vmind.online`

## Prerequisites

1. Domain managed by Cloudflare (vmind.online)
2. Cloudflare API Token
3. GitHub repository secrets configured

## Step 1: Create Cloudflare API Token

### Go to Cloudflare Dashboard

1. Login: https://dash.cloudflare.com
2. Click on your profile (top right)
3. Select: **My Profile** → **API Tokens**
4. Click: **Create Token**

### Configure Token

1. Use template: **Edit zone DNS**
2. Or create custom with permissions:
   - Zone → DNS → Edit
   - Zone → Zone → Read
3. Zone Resources:
   - Include → Specific zone → vmind.online
4. Click: **Continue to summary**
5. Click: **Create Token**
6. **Copy the token** (you won't see it again!)

## Step 2: Add Secrets to GitHub

### Go to GitHub Repository

https://github.com/red9inja/red9inja-GPT-INFRA

### Add Secrets

Settings → Secrets and variables → Actions → New repository secret

Add:
1. **CLOUDFLARE_API_TOKEN**
   - Value: Paste the API token from Step 1

2. **AWS_ACCESS_KEY_ID** (if not already added)
   - Value: Your AWS access key

3. **AWS_SECRET_ACCESS_KEY** (if not already added)
   - Value: Your AWS secret key

## Step 3: Configure Cloudflare SSL/TLS

### In Cloudflare Dashboard

1. Select your domain: **vmind.online**
2. Go to: **SSL/TLS** → **Overview**
3. Set encryption mode: **Full (strict)** or **Full**
4. Go to: **SSL/TLS** → **Edge Certificates**
5. Enable: **Always Use HTTPS**
6. Enable: **Automatic HTTPS Rewrites**

## How It Works

### Deployment Flow

```
1. Push code to branch (e.g., dev)
         ↓
2. Terraform creates EKS cluster
         ↓
3. Application deployed to Kubernetes
         ↓
4. Load Balancer created
         ↓
5. Cloudflare DNS workflow runs
         ↓
6. Creates CNAME: dev.vmind.online → ALB hostname
         ↓
7. Cloudflare proxies traffic (SSL + DDoS protection)
```

### DNS Records Created

| Branch | Subdomain | Points To |
|--------|-----------|-----------|
| dev | dev.vmind.online | ALB hostname |
| test | test.vmind.online | ALB hostname |
| staging | staging.vmind.online | ALB hostname |
| prod | gpt.vmind.online | ALB hostname |

## Cloudflare Benefits

1. **Free SSL Certificate** - Automatic HTTPS
2. **DDoS Protection** - Built-in security
3. **CDN** - Faster global access
4. **Analytics** - Traffic insights
5. **Firewall** - WAF rules
6. **Caching** - Improved performance

## Access Your Application

After deployment (5-10 minutes):

### Development
```
https://dev.vmind.online
```

### Testing
```
https://test.vmind.online
```

### Staging
```
https://staging.vmind.online
```

### Production
```
https://gpt.vmind.online
```

## Verify DNS

```bash
# Check DNS resolution
dig dev.vmind.online
nslookup dev.vmind.online

# Check with Cloudflare
dig dev.vmind.online @1.1.1.1
```

## Cloudflare Dashboard

View your DNS records:
1. Go to: https://dash.cloudflare.com
2. Select: **vmind.online**
3. Go to: **DNS** → **Records**

You'll see:
- dev.vmind.online → CNAME → ALB hostname (Proxied)
- test.vmind.online → CNAME → ALB hostname (Proxied)
- staging.vmind.online → CNAME → ALB hostname (Proxied)
- gpt.vmind.online → CNAME → ALB hostname (Proxied)

## Troubleshooting

### DNS not updating

Check:
- Cloudflare API token is valid
- Token has DNS edit permissions
- Zone name is correct (vmind.online)

### SSL errors

In Cloudflare:
- Set SSL/TLS mode to **Full** or **Flexible**
- Enable **Always Use HTTPS**

### Domain not accessible

Wait 2-5 minutes for:
- DNS propagation
- Cloudflare proxy activation
- SSL certificate provisioning

## Security Features

### Enable in Cloudflare

1. **Firewall Rules**
   - Block malicious traffic
   - Rate limiting

2. **Page Rules**
   - Cache settings
   - Security level

3. **Bot Fight Mode**
   - Block bad bots
   - Challenge suspicious traffic

4. **DDoS Protection**
   - Automatic mitigation
   - Always enabled

## Cost

- Cloudflare Free Plan: $0/month
  - Unlimited DNS queries
  - Free SSL certificates
  - Basic DDoS protection
  - CDN included

- Cloudflare Pro: $20/month (optional)
  - Advanced DDoS
  - WAF rules
  - Image optimization

## Workflow Files

- `.github/workflows/cloudflare-dns.yml` - DNS automation
- `.github/workflows/terraform-cicd.yml` - Infrastructure deployment

## Complete Setup Summary

1. Create Cloudflare API token
2. Add to GitHub secrets: `CLOUDFLARE_API_TOKEN`
3. Push to any branch
4. Automatic:
   - Infrastructure created
   - DNS record created
   - SSL enabled
   - Application accessible

## Example: Deploy to Dev

```bash
git checkout -b dev
git push origin dev
```

Wait 10 minutes, then access:
```
https://dev.vmind.online
```

## Manual DNS Update (if needed)

```bash
# Get load balancer hostname
kubectl get service red9inja-gpt-service

# Manually add in Cloudflare dashboard
# Type: CNAME
# Name: dev
# Target: ALB-hostname
# Proxy: Enabled
```

## Support

For issues:
- Check GitHub Actions logs
- Check Cloudflare audit log
- Verify API token permissions
