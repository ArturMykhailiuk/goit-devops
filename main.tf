# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "lesson-8-9"
      Environment = "development"
      ManagedBy   = "terraform"
    }
  }
}

# Local values for conditional provider configuration
locals {
  eks_cluster_endpoint = var.modules_config.eks && length(data.aws_eks_cluster.eks) > 0 ? data.aws_eks_cluster.eks[0].endpoint : ""
  eks_cluster_ca_certificate = var.modules_config.eks && length(data.aws_eks_cluster.eks) > 0 ? base64decode(data.aws_eks_cluster.eks[0].certificate_authority[0].data) : ""
  eks_cluster_token = var.modules_config.eks && length(data.aws_eks_cluster_auth.eks) > 0 ? data.aws_eks_cluster_auth.eks[0].token : ""
}

provider "helm" {
  kubernetes = {
    host                   = local.eks_cluster_endpoint
    cluster_ca_certificate = local.eks_cluster_ca_certificate
    token                  = local.eks_cluster_token
  }
}

provider "kubernetes" {
  host                   = local.eks_cluster_endpoint
  cluster_ca_certificate = local.eks_cluster_ca_certificate
  token                  = local.eks_cluster_token
}

# Terraform data resource for EKS synchronization
resource "terraform_data" "eks_ready" {
  count = var.modules_config.eks ? 1 : 0
  depends_on = [module.eks]
  
  triggers_replace = {
    cluster_name = var.modules_config.eks ? module.eks[0].cluster_name : ""
  }
}

# Cleanup resource to ensure proper destroy order
resource "terraform_data" "cleanup_complete" {
  count = var.modules_config.argo_cd && var.modules_config.eks ? 1 : 0
  depends_on = [module.argo_cd]
  
  triggers_replace = {
    argo_cd_cleanup = var.modules_config.argo_cd ? "argo_cd_apps_cleaned" : ""
  }
}

# Data sources for EKS cluster connection (with proper dependency)
data "aws_eks_cluster" "eks" {
  count = var.modules_config.eks ? 1 : 0
  name = module.eks[0].cluster_name
  depends_on = [terraform_data.eks_ready]
}

data "aws_eks_cluster_auth" "eks" {
  count = var.modules_config.eks ? 1 : 0
  name = module.eks[0].cluster_name
  depends_on = [terraform_data.eks_ready]
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

# S3 Backend (створюється першим)
module "s3_backend" {
  count = var.modules_config.s3_backend ? 1 : 0
  
  source      = "./modules/s3-backend"
  bucket_name = "artur-mykhailiuk-terraform-state"
  table_name  = "terraform-locks"
}

# Підключаємо модуль VPC
module "vpc" {
  count = var.modules_config.vpc ? 1 : 0
  
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc_name           = "lesson-8-9-vpc"
}

# Підключаємо модуль ECR
module "ecr" {
  count = var.modules_config.ecr ? 1 : 0
  
  source       = "./modules/ecr"
  ecr_name     = "lesson-8-9-ecr"
  scan_on_push = true
}

# Підключаємо модуль EKS
module "eks" {
  count = var.modules_config.eks ? 1 : 0
  
  source               = "./modules/eks"
  cluster_name         = "lesson-8-9-eks"
  subnet_ids           = var.modules_config.vpc ? module.vpc[0].private_subnet_ids : []
  node_instance_types  = ["t3.medium"]
}

# Відношення залежності для правильного порядку деструкції
resource "terraform_data" "destroy_order" {
  count = var.modules_config.argo_cd && var.modules_config.eks ? 1 : 0
  
  # EKS повинен видалятись після ArgoCD cleanup
  depends_on = [module.argo_cd]
  
  triggers_replace = {
    argo_cd_id = var.modules_config.argo_cd ? module.argo_cd[0].argo_cd_name : ""
    eks_id     = var.modules_config.eks ? module.eks[0].cluster_name : ""
  }
}

# Підключаємо модуль Jenkins
module "jenkins" {
  count = var.modules_config.jenkins && var.modules_config.eks ? 1 : 0
  
  source            = "./modules/jenkins"
  jenkins_name      = "jenkins"
  namespace         = "jenkins"
  helm_chart_version = "5.8.68"
  admin_password    = var.jenkins_admin_password
  kubeconfig   = var.kubeconfig_path
  cluster_name      = var.modules_config.eks ? module.eks[0].cluster_name : ""
  oidc_provider_arn = var.modules_config.eks ? module.eks[0].oidc_provider_arn : ""
  oidc_provider_url = var.modules_config.eks ? module.eks[0].oidc_provider_url : ""
  github_pat        = var.github_pat
}

# Підключаємо модуль Argo CD
module "argo_cd" {
  count = var.modules_config.argo_cd && var.modules_config.eks ? 1 : 0
  
  source         = "./modules/argo_cd"
  name           = "argo-cd"
  namespace      = "argocd"
  chart_version  = "5.51.6"
  values         = []
  
  depends_on = [terraform_data.eks_ready]
}

module "rds" {
  count = var.modules_config.rds && var.modules_config.vpc ? 1 : 0
  
  source = "./modules/rds"

  name                       = "myapp-db"
  use_aurora                 = false
  aurora_instance_count      = 2

  # --- Aurora-only ---
  engine_cluster             = "aurora-postgresql"
  engine_version_cluster     = "15.3"
  parameter_group_family_aurora = "aurora-postgresql15"
  

  # --- RDS-only ---
  engine                     = "postgres"
  engine_version             = "17.2"
  parameter_group_family_rds = "postgres17"

  # Common
  instance_class             = "db.t3.medium"
  allocated_storage          = 20
  db_name                    = "myapp"
  username                   = "postgres"
  password                   = "admin123AWS23"
  subnet_private_ids         = var.modules_config.vpc ? module.vpc[0].private_subnet_ids : []
  subnet_public_ids          = var.modules_config.vpc ? module.vpc[0].public_subnet_ids : []
  publicly_accessible        = false
  vpc_id                     = var.modules_config.vpc ? module.vpc[0].vpc_id : ""
  multi_az                   = true
  backup_retention_period    = 7
  skip_final_snapshot        = true
  parameters = {
    max_connections              = "200"
    log_min_duration_statement   = "500"
  }

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}