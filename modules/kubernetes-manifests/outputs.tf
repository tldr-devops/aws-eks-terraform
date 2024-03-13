output "chart" {
  description = "The name of the chart"
  value       = try(module.kubernetes_manifests.chart, null)
}

output "name" {
  description = "Name is the name of the release"
  value       = try(module.kubernetes_manifests.name, null)
}

output "namespace" {
  description = "Name of Kubernetes namespace"
  value       = try(module.kubernetes_manifests.namespace, null)
}

output "revision" {
  description = "Version is an int32 which represents the version of the release"
  value       = try(module.kubernetes_manifests.revision, null)
}

output "version" {
  description = "A SemVer 2 conformant version string of the chart"
  value       = try(module.kubernetes_manifests.version, null)
}

output "app_version" {
  description = "The version number of the application being deployed"
  value       = try(module.kubernetes_manifests.app_version, null)
}
