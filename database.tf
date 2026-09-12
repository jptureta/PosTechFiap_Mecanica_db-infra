# ─────────────────────────────────────────────────────────────
# Banco de Dados Gerenciado AWS RDS (PostgreSQL 16)
# ─────────────────────────────────────────────────────────────

data "aws_vpc" "default" {
  count   = var.vpc_id == "" ? 1 : 0
  default = true
}

data "aws_subnets" "default" {
  count = length(var.subnet_ids) == 0 ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [local.effective_vpc_id]
  }
}

locals {
  effective_vpc_id     = var.vpc_id != "" ? var.vpc_id : data.aws_vpc.default[0].id
  effective_subnet_ids = length(var.subnet_ids) > 0 ? var.subnet_ids : data.aws_subnets.default[0].ids
}

# 1. DB Subnet Group (obrigatoriamente multi-AZ)
resource "aws_db_subnet_group" "oficina" {
  name        = "oficina-db-subnet-group"
  description = "Subnet group para a instancia RDS PostgreSQL da Oficina Mecanica"
  subnet_ids  = local.effective_subnet_ids

  tags = {
    Name = "oficina-db-subnet-group"
  }
}

# 2. Security Group para acesso ao PostgreSQL
resource "aws_security_group" "rds" {
  name        = "oficina-rds-sg"
  description = "Controle de acesso para o banco de dados RDS PostgreSQL"
  vpc_id      = local.effective_vpc_id

  ingress {
    description = "Acesso PostgreSQL a partir da VPC / EKS / Lambdas"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }

  egress {
    description = "Permitir saida irrestrita"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "oficina-rds-sg"
  }
}

# 3. Parameter Group para PostgreSQL 16
resource "aws_db_parameter_group" "postgres16" {
  name        = "oficina-postgres16-params"
  family      = "postgres16"
  description = "Parametros customizados para o PostgreSQL 16 da Oficina"

  parameter {
    name  = "client_encoding"
    value = "UTF8"
  }
}

# 4. Instância Gerenciada AWS RDS PostgreSQL
resource "aws_db_instance" "postgres" {
  identifier = "oficina-postgres-db"

  engine         = "postgres"
  engine_version = "16"
  instance_class = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = "gp3"

  db_name  = var.db_name
  username = var.db_user
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.oficina.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.postgres16.name

  publicly_accessible = false
  skip_final_snapshot = true
  deletion_protection = false

  auto_minor_version_upgrade = true
  backup_retention_period    = 7

  tags = {
    Name = "oficina-postgres-db"
  }
}
