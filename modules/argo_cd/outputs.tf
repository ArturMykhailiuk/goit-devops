output "argo_cd_name" {
  value = helm_release.argo_cd.name
}

output "argo_cd_namespace" {
  value = helm_release.argo_cd.namespace
}
