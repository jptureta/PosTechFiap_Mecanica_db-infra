output "db_instance_endpoint" {
  description = "Endpoint de conexao da instancia RDS (host:porta)"
  value       = aws_db_instance.postgres.endpoint
}

output "db_instance_address" {
  description = "Hostname/Endereco DNS do RDS PostgreSQL"
  value       = aws_db_instance.postgres.address
}

output "db_instance_port" {
  description = "Porta de conexao do RDS PostgreSQL"
  value       = aws_db_instance.postgres.port
}

output "db_name" {
  description = "Nome do banco de dados configurado no RDS"
  value       = aws_db_instance.postgres.db_name
}

output "db_security_group_id" {
  description = "ID do Security Group associado ao RDS"
  value       = aws_security_group.rds.id
}

