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
