#!/bin/bash
set -e

echo "Deploying red9inja-GPT to EKS..."

AWS_REGION=${AWS_REGION:-us-east-1}
CLUSTER_NAME=${CLUSTER_NAME:-red9inja-gpt-cluster}
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "Configuring kubectl..."
aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

echo "Updating deployment with ECR image..."
sed -i "s/ACCOUNT_ID/$AWS_ACCOUNT_ID/g" k8s/deployment.yaml

echo "Applying Kubernetes manifests..."
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/hpa.yaml

echo "Waiting for deployment to be ready..."
kubectl rollout status deployment/red9inja-gpt

echo "Getting service endpoint..."
kubectl get service red9inja-gpt-service

echo "Deployment complete!"
echo "Check status: kubectl get pods"
echo "View logs: kubectl logs -f deployment/red9inja-gpt"
