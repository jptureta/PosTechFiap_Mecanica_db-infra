variable "cluster_name" {
  description = "Nome do cluster kind"
  type        = string
  default     = "oficina-mecanica"
}

variable "namespace" {
  description = "Namespace Kubernetes onde a aplicação e o banco serão implantados"
  type        = string
  default     = "oficina"
}

variable "db_name" {
  description = "Nome do banco de dados da aplicação"
  type        = string
  default     = "oficina_db"
}

variable "db_user" {
  description = "Usuário do banco de dados"
  type        = string
  default     = "oficina"
}

variable "db_password" {
  description = "Senha do banco de dados (definir via terraform.tfvars ou TF_VAR_db_password — nunca commitar)"
  type        = string
  sensitive   = true
}

variable "db_storage_size" {
  description = "Tamanho do volume persistente do PostgreSQL"
  type        = string
  default     = "1Gi"
}
