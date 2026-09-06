variable "aws_region" {
  description = "Região da AWS para provisionamento do RDS"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "ID da VPC onde o RDS será alocado (se omitido, usará a default VPC)"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "Lista de IDs de subnets para o DB Subnet Group (mínimo 2 em AZs distintas)"
  type        = list(string)
  default     = []
}

variable "db_name" {
  description = "Nome do banco de dados da aplicação"
  type        = string
  default     = "oficina_db"
}

variable "db_user" {
  description = "Usuário master do banco de dados"
  type        = string
  default     = "oficina"
}

variable "db_password" {
  description = "Senha do banco de dados (definir via terraform.tfvars ou TF_VAR_db_password — nunca commitar)"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Tipo de instância para o RDS PostgreSQL"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "Armazenamento inicial alocado em GiB"
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "Limite superior para autoscaling de armazenamento em GiB"
  type        = number
  default     = 100
}
