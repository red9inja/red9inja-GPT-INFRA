resource "aws_cognito_user_pool" "gpt_users" {
  name = "${var.cluster_name}-users"

  # Username configuration
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # Password policy
  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }

  # Account recovery
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # User attributes
  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = false

    string_attribute_constraints {
      min_length = 5
      max_length = 256
    }
  }

  schema {
    name                = "name"
    attribute_data_type = "String"
    required            = true
    mutable             = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  # Email configuration
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # MFA configuration
  mfa_configuration = "OPTIONAL"

  software_token_mfa_configuration {
    enabled = true
  }

  # User pool add-ons
  user_pool_add_ons {
    advanced_security_mode = "ENFORCED"
  }

  # Deletion protection
  deletion_protection = "ACTIVE"

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-user-pool"
    }
  )
}

# App Client
resource "aws_cognito_user_pool_client" "gpt_client" {
  name         = "${var.cluster_name}-client"
  user_pool_id = aws_cognito_user_pool.gpt_users.id

  # OAuth flows
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  
  callback_urls = [
    "https://gpt.vmind.online/callback",
    "https://dev.vmind.online/callback",
    "https://test.vmind.online/callback",
    "https://staging.vmind.online/callback",
    "http://localhost:8000/callback"
  ]

  logout_urls = [
    "https://gpt.vmind.online/logout",
    "https://dev.vmind.online/logout",
    "https://test.vmind.online/logout",
    "https://staging.vmind.online/logout",
    "http://localhost:8000/logout"
  ]

  # Token validity
  access_token_validity  = 60  # minutes
  id_token_validity      = 60  # minutes
  refresh_token_validity = 30  # days

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  # Prevent user existence errors
  prevent_user_existence_errors = "ENABLED"

  # Read/Write attributes
  read_attributes = [
    "email",
    "email_verified",
    "name",
  ]

  write_attributes = [
    "email",
    "name",
  ]

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]
}

# Domain for hosted UI
resource "aws_cognito_user_pool_domain" "gpt_domain" {
  domain       = "${var.cluster_name}-auth"
  user_pool_id = aws_cognito_user_pool.gpt_users.id
}

# User groups
resource "aws_cognito_user_group" "admin" {
  name         = "admin"
  user_pool_id = aws_cognito_user_pool.gpt_users.id
  description  = "Admin users with full access"
  precedence   = 1
}

resource "aws_cognito_user_group" "users" {
  name         = "users"
  user_pool_id = aws_cognito_user_pool.gpt_users.id
  description  = "Regular users"
  precedence   = 2
}

resource "aws_cognito_user_group" "premium" {
  name         = "premium"
  user_pool_id = aws_cognito_user_pool.gpt_users.id
  description  = "Premium users with extended limits"
  precedence   = 3
}
