resource "helm_release" "argo_cd" {
  name       = var.name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version
  namespace  = var.namespace

  create_namespace = true

  values = var.values
}

# Створення Argo CD Application через kubernetes_manifest
resource "kubernetes_manifest" "django_app" {
  manifest = yamldecode(file("${path.module}/charts/templates/application.yaml"))
  depends_on = [helm_release.argo_cd]
}
