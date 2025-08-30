provider "kubernetes" {
  config_path = var.kubeconfig_path
}

provider "helm" {
  kubernetes = {
    config_path = var.kubeconfig_path
  }
}

provider "argocd" {
  server_addr = var.argocd_server_addr
  username    = var.argocd_admin_username
  password    = var.argocd_admin_password
  insecure    = true
}
