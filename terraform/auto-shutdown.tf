resource "aws_lambda_function" "auto_shutdown" {
  count = var.environment != "prod" ? 1 : 0

  filename      = "lambda_shutdown.zip"
  function_name = "${var.cluster_name}-auto-shutdown"
  role          = aws_iam_role.lambda_shutdown[0].arn
  handler       = "index.handler"
  runtime       = "python3.11"

  environment {
    variables = {
      CLUSTER_NAME = var.cluster_name
      ENVIRONMENT  = var.environment
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-auto-shutdown"
    }
  )
}

resource "aws_iam_role" "lambda_shutdown" {
  count = var.environment != "prod" ? 1 : 0

  name = "${var.cluster_name}-lambda-shutdown"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_shutdown" {
  count = var.environment != "prod" ? 1 : 0

  role = aws_iam_role.lambda_shutdown[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:UpdateNodegroupConfig",
          "eks:DescribeNodegroup",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# EventBridge rule to shutdown at night (8 PM)
resource "aws_cloudwatch_event_rule" "shutdown" {
  count = var.environment != "prod" ? 1 : 0

  name                = "${var.cluster_name}-shutdown"
  description         = "Shutdown dev/test cluster at night"
  schedule_expression = "cron(0 20 * * ? *)"
}

resource "aws_cloudwatch_event_target" "shutdown" {
  count = var.environment != "prod" ? 1 : 0

  rule      = aws_cloudwatch_event_rule.shutdown[0].name
  target_id = "lambda"
  arn       = aws_lambda_function.auto_shutdown[0].arn
}

# EventBridge rule to startup in morning (8 AM)
resource "aws_cloudwatch_event_rule" "startup" {
  count = var.environment != "prod" ? 1 : 0

  name                = "${var.cluster_name}-startup"
  description         = "Startup dev/test cluster in morning"
  schedule_expression = "cron(0 8 * * ? *)"
}

resource "aws_cloudwatch_event_target" "startup" {
  count = var.environment != "prod" ? 1 : 0

  rule      = aws_cloudwatch_event_rule.startup[0].name
  target_id = "lambda"
  arn       = aws_lambda_function.auto_shutdown[0].arn
}

resource "aws_lambda_permission" "allow_eventbridge_shutdown" {
  count = var.environment != "prod" ? 1 : 0

  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auto_shutdown[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.shutdown[0].arn
}

resource "aws_lambda_permission" "allow_eventbridge_startup" {
  count = var.environment != "prod" ? 1 : 0

  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auto_shutdown[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.startup[0].arn
}
