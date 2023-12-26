output "chart" {
  description = "The name of the chart"
  value       = try(module.ingress_apisix.chart, null)
}

output "name" {
  description = "Name is the name of the release"
  value       = try(module.ingress_apisix.name, null)
}

output "namespace" {
  description = "Name of Kubernetes namespace"
  value       = try(module.ingress_apisix.namespace, null)
}

output "revision" {
  description = "Version is an int32 which represents the version of the release"
  value       = try(module.ingress_apisix.revision, null)
}

output "version" {
  description = "A SemVer 2 conformant version string of the chart"
  value       = try(module.ingress_apisix.version, null)
}

output "app_version" {
  description = "The version number of the application being deployed"
  value       = try(module.ingress_apisix.app_version, null)
}

output "apisix_admin_key" {
  description = "The apisix admin key"
  value       = random_password.apisix_admin_key
}

output "apisix_viewer_key" {
  description = "The apisix viewer key"
  value       = random_password.apisix_viewer_key
}
