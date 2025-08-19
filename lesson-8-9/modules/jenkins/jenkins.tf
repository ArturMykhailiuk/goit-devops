resource "helm_release" "jenkins" {
  name       = var.jenkins_name
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  namespace  = kubernetes_namespace.jenkins.metadata[0].name
  version    = var.helm_chart_version
  values     = [file("${path.module}/values.yaml")]
}

resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.namespace
  }
}