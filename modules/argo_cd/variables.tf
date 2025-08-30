variable "name" {
  description = "Name of the Helm release."
  type        = string
  default     = "argo-cd"
}

variable "namespace" {
  description = "Namespace to install Argo CD."
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Version of the Argo CD Helm chart."
  type        = string
  default     = "5.51.6"
}

variable "values" {
  description = "Custom values for the Helm chart."
  type        = any
  default     = []
}
