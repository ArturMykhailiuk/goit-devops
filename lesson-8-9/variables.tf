variable "jenkins_admin_password" {
  description = "Jenkins admin password"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig file for Helm provider"
  type        = string
  default     = "~/.kube/config"
}
