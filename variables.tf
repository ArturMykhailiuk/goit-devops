# Конфігурація модулів - що встановлювати
variable "modules_config" {
  description = "Configuration for enabling/disabling modules"
  type = object({
    s3_backend = bool
    vpc        = bool
    ecr        = bool
    eks        = bool
    jenkins    = bool
    argo_cd    = bool
    rds        = bool
  })
  default = {
    s3_backend = true
    vpc        = true
    ecr        = true
    eks        = true
    jenkins    = false  # За замовчуванням вимкнено
    argo_cd    = false  # За замовчуванням вимкнено
    rds        = false  # За замовчуванням вимкнено
  }
}

variable "jenkins_admin_password" {
  description = "Jenkins admin password"
  type        = string
  sensitive   = true
  default     = "admin"
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "github_pat" {
  description = "GitHub Personal Access Token for Jenkins"
  type        = string
  sensitive   = true
  default     = "dummy-token"
}