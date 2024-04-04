################################################################################
# Helm Release
################################################################################

output "chart" {
  description = "The name of the chart"
  value       = try(module.openobserve-collector.chart, null)
}

output "name" {
  description = "Name is the name of the release"
  value       = try(module.openobserve-collector.name, null)
}

output "namespace" {
  description = "Name of Kubernetes namespace"
  value       = try(module.openobserve-collector.namespace, null)
}

output "revision" {
  description = "Version is an int32 which represents the version of the release"
  value       = try(module.openobserve-collector.revision, null)
}

output "version" {
  description = "A SemVer 2 conformant version string of the chart"
  value       = try(module.openobserve-collector.version, null)
}

output "app_version" {
  description = "The version number of the application being deployed"
  value       = try(module.openobserve-collector.app_version, null)
}

# output "values" {
#   description = "The compounded values from `values` and `set*` attributes"
#   value       = try(module.openobserve-collector.values, [])
# }

################################################################################
# IAM Role for Service Account(s) (IRSA)
################################################################################

output "iam_role_arn" {
  description = "ARN of IAM role"
  value       = try(module.openobserve-collector.iam_role_arn, null)
}

output "iam_role_name" {
  description = "Name of IAM role"
  value       = try(module.openobserve-collector.iam_role_name, null)
}

output "iam_role_path" {
  description = "Path of IAM role"
  value       = try(module.openobserve-collector.iam_role_name, null)
}

output "iam_role_unique_id" {
  description = "Unique ID of IAM role"
  value       = try(module.openobserve-collector.iam_role_unique_id, null)
}

################################################################################
# IAM Policy
################################################################################

output "iam_policy_arn" {
  description = "The ARN assigned by AWS to this policy"
  value       = try(module.openobserve-collector.iam_policy_arn, null)
}

output "iam_policy" {
  description = "The policy document"
  value       = try(module.openobserve-collector.iam_policy, null)
}
