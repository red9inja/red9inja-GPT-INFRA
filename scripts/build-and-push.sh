#!/bin/bash
set -e

echo "Building and pushing Docker image to ECR..."

AWS_REGION=${AWS_REGION:-us-east-1}
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/red9inja-gpt"
IMAGE_TAG=${IMAGE_TAG:-latest}

echo "AWS Account: $AWS_ACCOUNT_ID"
echo "ECR Repository: $ECR_REPO"
echo "Image Tag: $IMAGE_TAG"

echo "Logging in to ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO

echo "Building Docker image..."
cd ../red9inja-GPT
docker build -t red9inja-gpt:$IMAGE_TAG -f ../red9inja-GPT-INFRA/docker/Dockerfile .

echo "Tagging image..."
docker tag red9inja-gpt:$IMAGE_TAG $ECR_REPO:$IMAGE_TAG

echo "Pushing image to ECR..."
docker push $ECR_REPO:$IMAGE_TAG

echo "Image pushed successfully!"
echo "Image URI: $ECR_REPO:$IMAGE_TAG"
