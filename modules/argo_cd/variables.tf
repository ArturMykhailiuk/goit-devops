variable "name" {
  description = "Release name for Argo CD"
  type        = string
}

variable "namespace" {
  description = "Namespace for Argo CD"
  type        = string
}

variable "chart_version" {
  description = "Argo CD Helm chart version"
  type        = string
}
variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
}
variable "argo_cd_repo_url" {
  description = "Helm repo URL for Argo CD"
  type        = string
  default     = "https://argoproj.github.io/argo-helm"
}

variable "argo_cd_chart_version" {
  description = "Argo CD Helm chart version"
  type        = string
  default     = "5.51.6"
}

variable "argo_cd_namespace" {
  description = "Namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "argocd_server_addr" {
  description = "Argo CD server address (host:port, наприклад, argocd.example.com або argocd-server.argocd.svc:443)"
  type        = string
}

variable "argocd_admin_username" {
  description = "Argo CD admin username"
  type        = string
  default     = "admin"
}

variable "argocd_admin_password" {
  description = "Argo CD admin password"
  type        = string
  default     = "admin"
}

