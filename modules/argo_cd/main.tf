resource "helm_release" "argo_cd" {
  name       = var.name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version
  namespace  = var.namespace
  timeout    = 600  # Збільшено до 10 хвилин
  create_namespace = true
  values = var.values
}

# ArgoCD Applications chart з values.yaml
resource "helm_release" "argo_cd_apps" {
  name       = "argo-cd-apps"
  chart      = "${path.module}/charts"
  namespace  = var.namespace
  timeout    = 300
  depends_on = [helm_release.argo_cd]
}

