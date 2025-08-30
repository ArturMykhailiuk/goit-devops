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

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

terraform {
  required_providers {
    argocd = {
      source  = "argoproj-labs/argocd"
      version = ">= 2.0.0"
    }
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
  source      = "./modules/s3-backend"
  bucket_name = "artur-mykhailiuk-terraform-state"
  table_name  = "terraform-locks"
}

# Підключаємо модуль VPC
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc_name           = "lesson-8-9-vpc"
}

# Підключаємо модуль ECR
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "lesson-8-9-ecr"
  scan_on_push = true
}

# Підключаємо модуль EKS
module "eks" {
  source        = "./modules/eks"
  cluster_name  = "lesson-8-9-eks"
  subnet_ids    = module.vpc.private_subnet_ids
}

# Підключаємо модуль Jenkins
module "jenkins" {
  source            = "./modules/jenkins"
  jenkins_name      = "jenkins"
  namespace         = "jenkins"
  helm_chart_version = "5.8.68"
  admin_password    = var.jenkins_admin_password
  kubeconfig   = var.kubeconfig_path
  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
}

# Підключаємо модуль ArgoCD
module "argo_cd" {
  source                = "./modules/argo_cd"
  argo_cd_namespace     = "argocd"
  argo_cd_chart_version = "5.51.6"
  kubeconfig_path       = var.kubeconfig_path
  name                  = "argo-cd"
  namespace             = "argocd"
  chart_version         = "8.3.1"

  argocd_server_addr    = var.argocd_server_addr
}
