resource "aws_s3_bucket" "model_checkpoints" {
  bucket = "${var.cluster_name}-model-checkpoints"

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-model-checkpoints"
    }
  )
}

resource "aws_s3_bucket_versioning" "model_checkpoints" {
  bucket = aws_s3_bucket.model_checkpoints.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "model_checkpoints" {
  bucket = aws_s3_bucket.model_checkpoints.id

  rule {
    id     = "delete-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }

  rule {
    id     = "transition-to-glacier"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "model_checkpoints" {
  bucket = aws_s3_bucket.model_checkpoints.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_policy" "s3_checkpoints_access" {
  name        = "${var.cluster_name}-s3-checkpoints"
  description = "Allow EKS pods to access S3 checkpoints"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.model_checkpoints.arn,
          "${aws_s3_bucket.model_checkpoints.arn}/*"
        ]
      }
    ]
  })
}

# CloudFront for CDN
resource "aws_cloudfront_distribution" "cdn" {
  enabled = true
  comment = "${var.cluster_name} CDN"

  origin {
    domain_name = aws_s3_bucket.model_checkpoints.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.model_checkpoints.id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cdn.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.model_checkpoints.id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-cdn"
    }
  )
}

resource "aws_cloudfront_origin_access_identity" "cdn" {
  comment = "${var.cluster_name} CDN OAI"
}
