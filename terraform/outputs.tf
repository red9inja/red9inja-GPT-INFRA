output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.red9inja_gpt.repository_url
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.gpt_users.id
}

output "cognito_user_pool_arn" {
  description = "Cognito User Pool ARN"
  value       = aws_cognito_user_pool.gpt_users.arn
}

output "cognito_client_id" {
  description = "Cognito App Client ID"
  value       = aws_cognito_user_pool_client.gpt_client.id
  sensitive   = true
}

output "cognito_domain" {
  description = "Cognito Hosted UI Domain"
  value       = "https://${aws_cognito_user_pool_domain.gpt_domain.domain}.auth.${var.aws_region}.amazoncognito.com"
}

output "cognito_login_url" {
  description = "Cognito Login URL"
  value       = "https://${aws_cognito_user_pool_domain.gpt_domain.domain}.auth.${var.aws_region}.amazoncognito.com/login?client_id=${aws_cognito_user_pool_client.gpt_client.id}&response_type=code&redirect_uri=https://gpt.vmind.online/callback"
}

output "dynamodb_conversations_table" {
  description = "DynamoDB conversations table name"
  value       = aws_dynamodb_table.conversations.name
}

output "dynamodb_messages_table" {
  description = "DynamoDB messages table name"
  value       = aws_dynamodb_table.messages.name
}

output "redis_endpoint" {
  description = "Redis cluster endpoint"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "redis_port" {
  description = "Redis port"
  value       = aws_elasticache_replication_group.redis.port
}

output "sqs_queue_url" {
  description = "SQS queue URL"
  value       = aws_sqs_queue.generation_queue.url
}

output "sonarqube_db_endpoint" {
  description = "SonarQube RDS endpoint"
  value       = aws_db_instance.sonarqube.address
}

output "sonarqube_secret_id" {
  description = "SonarQube database secret ID"
  value       = aws_secretsmanager_secret.sonarqube_db.id
}
