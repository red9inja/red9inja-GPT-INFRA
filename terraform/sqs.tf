resource "aws_sqs_queue" "generation_queue" {
  name                       = "${var.cluster_name}-generation-queue"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 10
  visibility_timeout_seconds = 300

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.generation_dlq.arn
    maxReceiveCount     = 3
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-generation-queue"
    }
  )
}

resource "aws_sqs_queue" "generation_dlq" {
  name                      = "${var.cluster_name}-generation-dlq"
  message_retention_seconds = 1209600

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-generation-dlq"
    }
  )
}

resource "aws_iam_policy" "sqs_access" {
  name        = "${var.cluster_name}-sqs-access"
  description = "Allow EKS pods to access SQS queues"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Resource = [
          aws_sqs_queue.generation_queue.arn,
          aws_sqs_queue.generation_dlq.arn
        ]
      }
    ]
  })
}
