#!/bin/bash
set -e

echo "Deploying SonarQube to EKS..."

# Get RDS credentials from Terraform
echo "Getting RDS credentials..."
RDS_ENDPOINT=$(terraform output -raw sonarqube_db_endpoint 2>/dev/null || echo "")
RDS_PASSWORD=$(aws secretsmanager get-secret-value --secret-id $(terraform output -raw sonarqube_secret_id) --query SecretString --output text | jq -r '.password')

if [ -z "$RDS_ENDPOINT" ]; then
    echo "Error: RDS endpoint not found. Run terraform apply first."
    exit 1
fi

echo "RDS Endpoint: $RDS_ENDPOINT"

# Update secret with RDS credentials
echo "Creating Kubernetes secret..."
kubectl create namespace sonarqube --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic sonarqube-db \
    --from-literal=username=sonarqube \
    --from-literal=password="$RDS_PASSWORD" \
    --from-literal=jdbc-url="jdbc:postgresql://$RDS_ENDPOINT:5432/sonarqube" \
    --namespace=sonarqube \
    --dry-run=client -o yaml | kubectl apply -f -

# Deploy SonarQube
echo "Deploying SonarQube..."
kubectl apply -f k8s/sonarqube.yaml

# Wait for deployment
echo "Waiting for SonarQube to be ready..."
kubectl wait --for=condition=available --timeout=600s deployment/sonarqube -n sonarqube

# Get Load Balancer URL
echo "Getting SonarQube URL..."
LB_URL=$(kubectl get service sonarqube -n sonarqube -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo ""
echo "SonarQube deployed successfully!"
echo "URL: http://$LB_URL"
echo ""
echo "Default credentials:"
echo "  Username: admin"
echo "  Password: admin"
echo ""
echo "IMPORTANT: Change the default password on first login!"
