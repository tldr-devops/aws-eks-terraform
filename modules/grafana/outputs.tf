output "chart" {
  description = "The name of the chart"
  value       = try(module.grafana.chart, null)
}

output "name" {
  description = "Name is the name of the release"
  value       = try(module.grafana.name, null)
}

output "namespace" {
  description = "Name of Kubernetes namespace"
  value       = try(module.grafana.namespace, null)
}

output "revision" {
  description = "Version is an int32 which represents the version of the release"
  value       = try(module.grafana.revision, null)
}

output "version" {
  description = "A SemVer 2 conformant version string of the chart"
  value       = try(module.grafana.version, null)
}

output "app_version" {
  description = "The version number of the application being deployed"
  value       = try(module.grafana.app_version, null)
}

# output "values" {
#   description = "The compounded values from `values` and `set*` attributes"
#   value       = try(module.grafana.values, null)
# }

################################################################################
# Grafana
################################################################################

output "admin_password" {
  description = "Grafana admin password"
  value       = local.admin_password
  sensitive   = true
}

output "admin_user" {
  description = "Grafana admin user"
  value       = var.admin_user
}

output "grafana_operator_integration" {
  description = "Are integration with Grafana Operator is enabled"
  value       = var.grafana_operator_integration
}
