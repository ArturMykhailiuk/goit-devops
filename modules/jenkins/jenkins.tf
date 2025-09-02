resource "helm_release" "jenkins" {
  name       = var.jenkins_name
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  namespace  = kubernetes_namespace.jenkins.metadata[0].name
  version    = "5.0.16"
  values     = [file("${path.module}/values.yaml")]
  timeout    = 180
  create_namespace = true

  # Pre-destroy hook для коректного видалення StatefulSet
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete sts jenkins -n jenkins --force --grace-period=0 2>/dev/null || true"
  }

  # Додатковий hook для видалення PVC
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete pvc jenkins -n jenkins --force --grace-period=0 2>/dev/null || true"
  }
  set_sensitive = [
    {
      name  = "controller.admin.password"
      value = var.admin_password
    },
    {
      name  = "controller.JCasC.configScripts.credentials"
      value = <<-EOT
        credentials:
          system:
            domainCredentials:
              - credentials:
                  - string:
                      scope: GLOBAL
                      id: github-token
                      secret: ${var.github_pat}
                      description: GitHub PAT
      EOT
    }
  ]
}
resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_service_account" "jenkins_sa" {
  metadata {
    name      = "jenkins-sa"
    namespace = "jenkins"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.jenkins_kaniko_role.arn
    }
  }
  depends_on = [
    helm_release.jenkins
  ]
}

resource "aws_iam_role" "jenkins_kaniko_role" {
  name = "${var.cluster_name}-jenkins-kaniko-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = var.oidc_provider_arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:jenkins:jenkins-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "jenkins_ecr_policy" {
  name = "${var.cluster_name}-jenkins-kaniko-ecr-policy"
  role = aws_iam_role.jenkins_kaniko_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories"
        ],
        Resource = "*"
      }
    ]
  })
}

