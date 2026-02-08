#!/bin/bash
set -e

echo "WARNING: This will destroy all infrastructure!"
read -p "Are you sure? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 0
fi

echo "Deleting Kubernetes resources..."
kubectl delete -f k8s/ --ignore-not-found=true

echo "Waiting for resources to be deleted..."
sleep 30

echo "Destroying Terraform infrastructure..."
cd terraform
terraform destroy -auto-approve

echo "Cleanup complete!"
