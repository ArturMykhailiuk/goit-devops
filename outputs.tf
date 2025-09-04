# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = var.modules_config.vpc && length(module.vpc) > 0 ? module.vpc[0].vpc_id : null
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = var.modules_config.vpc && length(module.vpc) > 0 ? module.vpc[0].vpc_cidr_block : null
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = var.modules_config.vpc && length(module.vpc) > 0 ? module.vpc[0].public_subnet_ids : []
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = var.modules_config.vpc && length(module.vpc) > 0 ? module.vpc[0].private_subnet_ids : []
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = var.modules_config.vpc && length(module.vpc) > 0 ? module.vpc[0].internet_gateway_id : null
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = var.modules_config.vpc && length(module.vpc) > 0 ? module.vpc[0].nat_gateway_ids : []
}

# ECR Outputs
output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = var.modules_config.ecr && length(module.ecr) > 0 ? module.ecr[0].repository_url : null
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = var.modules_config.ecr && length(module.ecr) > 0 ? module.ecr[0].repository_arn : null
}

output "ecr_registry_id" {
  description = "Registry ID of the ECR repository"
  value       = var.modules_config.ecr && length(module.ecr) > 0 ? module.ecr[0].registry_id : null
}

# EKS Outputs
output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = var.modules_config.eks && length(module.eks) > 0 ? module.eks[0].cluster_name : null
}

output "eks_cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  value       = var.modules_config.eks && length(module.eks) > 0 ? module.eks[0].endpoint : null
}

# Jenkins Outputs
output "jenkins_release" {
  description = "Jenkins Helm release name"
  value = var.modules_config.jenkins && length(module.jenkins) > 0 ? module.jenkins[0].jenkins_release_name : null
}

output "jenkins_namespace" {
  description = "Jenkins Kubernetes namespace"
  value = var.modules_config.jenkins && length(module.jenkins) > 0 ? module.jenkins[0].jenkins_namespace : null
}

# RDS Outputs
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value = var.modules_config.rds && length(module.rds) > 0 ? module.rds[0].endpoint : null
}

# Modules status
output "enabled_modules" {
  description = "List of enabled modules"
  value = [
    for module_name, enabled in var.modules_config : module_name if enabled
  ]
}