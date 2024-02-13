################################################################################
# Helm Release
################################################################################

output "chart" {
  description = "The name of the chart"
  value       = try(module.qryn.chart, null)
}

output "name" {
  description = "Name is the name of the release"
  value       = try(module.qryn.name, null)
}

output "namespace" {
  description = "Name of Kubernetes namespace"
  value       = try(module.qryn.namespace, null)
}

output "revision" {
  description = "Version is an int32 which represents the version of the release"
  value       = try(module.qryn.revision, null)
}

output "version" {
  description = "A SemVer 2 conformant version string of the chart"
  value       = try(module.qryn.version, null)
}

output "app_version" {
  description = "The version number of the application being deployed"
  value       = try(module.qryn.app_version, null)
}

output "values" {
  description = "The compounded values from `values` and `set*` attributes"
  value       = try(module.qryn.values, [])
}

################################################################################
# IAM Role for Service Account(s) (IRSA)
################################################################################

output "iam_role_arn" {
  description = "ARN of IAM role"
  value       = try(module.role.iam_role_arn, null)
}

output "iam_role_name" {
  description = "Name of IAM role"
  value       = try(module.role.iam_role_name, null)
}

output "iam_role_path" {
  description = "Path of IAM role"
  value       = try(module.role.iam_role_name, null)
}

output "iam_role_unique_id" {
  description = "Unique ID of IAM role"
  value       = try(module.role.iam_role_unique_id, null)
}

################################################################################
# IAM Policy
################################################################################

output "iam_policy_arn" {
  description = "The ARN assigned by AWS to this policy"
  value       = try(module.role.iam_policy_arn, null)
}

output "iam_policy" {
  description = "The policy document"
  value       = try(module.role.iam_policy, null)
}

################################################################################
# Qryn
################################################################################

output "root_password" {
  description = "The qryn root password"
  value       = local.root_password
}

output "clickhouse_password" {
  description = "The qryn clickhouse password"
  value       = random_password.clickhouse_password.result
}
