################################################################################
# Helm Release
################################################################################

output "chart" {
  description = "The name of the chart"
  value       = {
    uptrace     = try(module.uptrace.chart, null)
    clickhouse  = try(module.clickhouse.chart, null)
    postgresql  = try(module.postgresql.chart, null)
  }
}

output "name" {
  description = "Name is the name of the release"
  value       = {
    uptrace     = try(module.uptrace.name, null)
    clickhouse  = try(module.clickhouse.name, null)
    postgresql  = try(module.postgresql.name, null)
  }
}

output "namespace" {
  description = "Name of Kubernetes namespace"
  value       = {
    uptrace     = try(module.uptrace.namespace, null)
    clickhouse  = try(module.clickhouse.namespace, null)
    postgresql  = try(module.postgresql.namespace, null)
  }
}

output "revision" {
  description = "Version is an int32 which represents the version of the release"
  value       = {
    uptrace        = try(module.uptrace.revision, null)
    clickhouse  = try(module.clickhouse.revision, null)
  }
}

output "version" {
  description = "A SemVer 2 conformant version string of the chart"
  value       = {
    uptrace     = try(module.uptrace.version, null)
    clickhouse  = try(module.clickhouse.version, null)
    postgresql  = try(module.postgresql.version, null)
  }
}

output "app_version" {
  description = "The version number of the application being deployed"
  value       = {
    uptrace        = try(module.uptrace.app_version, null)
    clickhouse  = try(module.clickhouse.app_version, null)
    postgresql  = try(module.postgresql.app_version, null)
  }
}

output "values" {
  description = "The compounded values from `values` and `set*` attributes"
  value       = {
    uptrace        = try(module.uptrace.values, [])
    clickhouse  = try(module.clickhouse.values, [])
    postgresql  = try(module.postgresql.values, [])
  }
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
# Uptrace
################################################################################

output "root_password" {
  description = "The uptrace root password"
  value       = local.root_password
  sensitive   = true
}

output "project_tokens" {
  description = "The uptrace project tokens"
  value       = random_password.uptrace_project_tokens[*].result
  sensitive   = true
}

output "clickhouse_password" {
  description = "The uptrace clickhouse password"
  value       = random_password.clickhouse_password.result
  sensitive   = true
}

output "postgresql_password" {
  description = "The uptrace postgresql password"
  value       = random_password.postgresql_password.result
  sensitive   = true
}
