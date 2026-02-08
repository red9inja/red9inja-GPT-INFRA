resource "aws_secretsmanager_secret" "app_secrets" {
  name                    = "${var.cluster_name}-app-secrets"
  description             = "Application secrets for red9inja-GPT"
  recovery_window_in_days = 7

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-app-secrets"
    }
  )
}

resource "aws_secretsmanager_secret_version" "app_secrets" {
  secret_id = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    cognito_user_pool_id = aws_cognito_user_pool.gpt_users.id
    cognito_client_id    = aws_cognito_user_pool_client.gpt_client.id
    redis_host           = aws_elasticache_replication_group.redis.primary_endpoint_address
    redis_port           = aws_elasticache_replication_group.redis.port
    dynamodb_conversations_table = aws_dynamodb_table.conversations.name
    dynamodb_messages_table      = aws_dynamodb_table.messages.name
    sqs_queue_url        = aws_sqs_queue.generation_queue.url
  })
}

resource "aws_iam_policy" "secrets_access" {
  name        = "${var.cluster_name}-secrets-access"
  description = "Allow EKS pods to access Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_secretsmanager_secret.app_secrets.arn
      }
    ]
  })
}
