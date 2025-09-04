# Provider configurations moved to root module
# Providers are now configured in main.tf

variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}
