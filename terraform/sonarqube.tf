resource "aws_db_instance" "sonarqube" {
  identifier = "${var.cluster_name}-sonarqube-db"
  
  engine         = "postgres"
  engine_version = "13.13"
  instance_class = "db.t3.small"
  
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true
  
  db_name  = "sonarqube"
  username = "sonarqube"
  password = random_password.sonarqube_db.result
  
  vpc_security_group_ids = [aws_security_group.sonarqube_db.id]
  db_subnet_group_name   = aws_db_subnet_group.sonarqube.name
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"
  
  skip_final_snapshot       = var.environment != "prod"
  final_snapshot_identifier = var.environment == "prod" ? "${var.cluster_name}-sonarqube-final" : null
  
  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-sonarqube-db"
    }
  )
}

resource "aws_db_subnet_group" "sonarqube" {
  name       = "${var.cluster_name}-sonarqube-subnet"
  subnet_ids = module.vpc.private_subnets
  
  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-sonarqube-subnet"
    }
  )
}

resource "aws_security_group" "sonarqube_db" {
  name        = "${var.cluster_name}-sonarqube-db-sg"
  description = "Security group for SonarQube RDS"
  vpc_id      = module.vpc.vpc_id
  
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-sonarqube-db-sg"
    }
  )
}

resource "random_password" "sonarqube_db" {
  length  = 16
  special = true
}

resource "aws_secretsmanager_secret" "sonarqube_db" {
  name                    = "${var.cluster_name}-sonarqube-db-credentials"
  description             = "SonarQube database credentials"
  recovery_window_in_days = 7
  
  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-sonarqube-db-credentials"
    }
  )
}

resource "aws_secretsmanager_secret_version" "sonarqube_db" {
  secret_id = aws_secretsmanager_secret.sonarqube_db.id
  secret_string = jsonencode({
    username = aws_db_instance.sonarqube.username
    password = random_password.sonarqube_db.result
    host     = aws_db_instance.sonarqube.address
    port     = aws_db_instance.sonarqube.port
    database = aws_db_instance.sonarqube.db_name
    jdbc_url = "jdbc:postgresql://${aws_db_instance.sonarqube.address}:${aws_db_instance.sonarqube.port}/${aws_db_instance.sonarqube.db_name}"
  })
}
