variable "jenkins_name" {
  description = "Jenkins Helm release name"
  type        = string
  default     = "jenkins"
}

variable "namespace" {
  description = "Kubernetes namespace for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "helm_chart_version" {
  description = "Jenkins Helm chart version"
  type        = string
  default     = "5.8.68"
}

variable "admin_password" {
  description = "Jenkins admin password"
  type        = string
  sensitive   = true
}

variable "cluster_name" {
  description = "EKS cluster name for IRSA role"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA role"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC provider URL for IRSA role"
  type        = string
}

variable "kubeconfig" {
  description = "Шлях до kubeconfig файлу"
  type        = string
}

variable "github_pat" {
  description = "GitHub Personal Access Token for Jenkins"
  type        = string
  sensitive   = true
}