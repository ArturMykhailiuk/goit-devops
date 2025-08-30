variable "jenkins_admin_password" {
  description = "Jenkins admin password"
  type        = string
  sensitive   = true
}
variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}
variable "argocd_server_addr" {
  description = "Argo CD server address (наприклад, argocd-server.argocd.svc:443)"
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
  sensitive   = true
}
