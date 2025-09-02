resource "helm_release" "argo_cd" {
  name       = var.name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version
  namespace  = var.namespace

  create_namespace = true

  # Pre-destroy hook для ArgoCD
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete pods -n argocd --all --force --grace-period=0 2>/dev/null || true"
  }

  values = var.values
}

# ArgoCD Application буде створено після встановлення ArgoCD
# resource "kubernetes_manifest" "django_app" {
#   manifest = yamldecode(file("${path.module}/charts/templates/application.yaml"))
#   depends_on = [helm_release.argo_cd]
# }
