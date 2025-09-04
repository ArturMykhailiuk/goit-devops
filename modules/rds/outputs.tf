# RDS Standard outputs
output "endpoint" {
  description = "The RDS instance endpoint"
  value       = var.use_aurora ? null : (length(aws_db_instance.standard) > 0 ? aws_db_instance.standard[0].endpoint : null)
}

output "port" {
  description = "The RDS instance port"  
  value       = var.use_aurora ? null : (length(aws_db_instance.standard) > 0 ? aws_db_instance.standard[0].port : null)
}

output "identifier" {
  description = "The RDS instance identifier"
  value       = var.use_aurora ? null : (length(aws_db_instance.standard) > 0 ? aws_db_instance.standard[0].identifier : null)
}

output "db_name" {
  description = "The database name"
  value       = var.db_name
}

output "username" {
  description = "The master username"
  value       = var.username
  sensitive   = true
}

# Aurora outputs  
output "aurora_endpoint" {
  description = "The Aurora cluster endpoint"
  value       = var.use_aurora ? (length(aws_rds_cluster.aurora) > 0 ? aws_rds_cluster.aurora[0].endpoint : null) : null
}

output "aurora_reader_endpoint" {
  description = "The Aurora cluster reader endpoint"
  value       = var.use_aurora ? (length(aws_rds_cluster.aurora) > 0 ? aws_rds_cluster.aurora[0].reader_endpoint : null) : null
}

# Common outputs
output "security_group_id" {
  description = "The RDS security group ID"
  value       = aws_security_group.rds.id
}

output "subnet_group_name" {
  description = "The DB subnet group name"
  value       = aws_db_subnet_group.default.name
}
