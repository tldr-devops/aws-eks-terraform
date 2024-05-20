variable "root_email" {
  description = "env.QRYN_LOGIN helm chart value"
  type        = string
}

variable "root_password" {
  description = "env.QRYN_PASSWORD helm chart value"
  type        = string
  default     = null
}

variable "grafana_operator_integration" {
  description = "Controls if Grafana instance should be connected to Grafana Operator"
  type        = bool
  default     = false
}

variable "grafana_operator_namespace" {
  description = "Grafana Operator namespace"
  type        = string
  default     = null
}

variable "create" {
  description = "Controls if resources should be created (affects all resources)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Helm Release
################################################################################

variable "create_release" {
  description = "Determines whether the Helm release is created"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name of the Helm release"
  type        = string
  default     = ""
}

variable "description" {
  description = "Set release description attribute (visible in the history)"
  type        = string
  default     = "Uptrace monitoring server"
}

variable "namespace" {
  description = "The namespace to install the release into. Defaults to `default`"
  type        = string
  default     = "uptrace"
}

variable "create_namespace" {
  description = "Create the namespace if it does not yet exist. Defaults to `false`"
  type        = bool
  default     = true
}

variable "chart" {
  description = "Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified"
  type        = string
  default     = "uptrace"
}

variable "chart_version" {
  description = "Specify the exact chart version to install. If this is not specified, the latest version is installed"
  type        = string
  default     = null
}

variable "repository" {
  description = "Repository URL where to locate the requested chart"
  type        = string
  default     = "https://charts.uptrace.dev"
}

variable "values" {
  description = "List of values in raw yaml to pass to helm. Values will be merged, in order, as Helm does with multiple `-f` options"
  type        = list(string)
  default     = null
}

variable "timeout" {
  description = "Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks). Defaults to `300` seconds"
  type        = number
  default     = null
}

variable "repository_key_file" {
  description = "The repositories cert key file"
  type        = string
  default     = null
}

variable "repository_cert_file" {
  description = "The repositories cert file"
  type        = string
  default     = null
}

variable "repository_ca_file" {
  description = "The Repositories CA File"
  type        = string
  default     = null
}

variable "repository_username" {
  description = "Username for HTTP basic authentication against the repository"
  type        = string
  default     = null
}

variable "repository_password" {
  description = "Password for HTTP basic authentication against the repository"
  type        = string
  default     = null
}

variable "devel" {
  description = "Use chart development versions, too. Equivalent to version '>0.0.0-0'. If version is set, this is ignored"
  type        = bool
  default     = null
}

variable "verify" {
  description = "Verify the package before installing it. Helm uses a provenance file to verify the integrity of the chart; this must be hosted alongside the chart. For more information see the Helm Documentation. Defaults to `false`"
  type        = bool
  default     = null
}

variable "keyring" {
  description = "Location of public keys used for verification. Used only if verify is true. Defaults to `/.gnupg/pubring.gpg` in the location set by `home`"
  type        = string
  default     = null
}

variable "disable_webhooks" {
  description = "Prevent hooks from running. Defaults to `false`"
  type        = bool
  default     = null
}

variable "reuse_values" {
  description = "When upgrading, reuse the last release's values and merge in any overrides. If `reset_values` is specified, this is ignored. Defaults to `false`"
  type        = bool
  default     = null
}

variable "reset_values" {
  description = "When upgrading, reset the values to the ones built into the chart. Defaults to `false`"
  type        = bool
  default     = true
}

variable "force_update" {
  description = "Force resource update through delete/recreate if needed. Defaults to `false`"
  type        = bool
  default     = null
}

variable "recreate_pods" {
  description = "Perform pods restart during upgrade/rollback. Defaults to `false`"
  type        = bool
  default     = null
}

variable "cleanup_on_fail" {
  description = "Allow deletion of new resources created in this upgrade when upgrade fails. Defaults to `false`"
  type        = bool
  default     = null
}

variable "max_history" {
  description = "Maximum number of release versions stored per release. Defaults to `0` (no limit)"
  type        = number
  default     = null
}

variable "atomic" {
  description = "If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used. Defaults to `false`"
  type        = bool
  default     = null
}

variable "skip_crds" {
  description = "If set, no CRDs will be installed. By default, CRDs are installed if not already present. Defaults to `false`"
  type        = bool
  default     = null
}

variable "render_subchart_notes" {
  description = "If set, render subchart notes along with the parent. Defaults to `true`"
  type        = bool
  default     = null
}

variable "disable_openapi_validation" {
  description = "If set, the installation process will not validate rendered templates against the Kubernetes OpenAPI Schema. Defaults to `false`"
  type        = bool
  default     = null
}

variable "wait" {
  description = "Will wait until all resources are in a ready state before marking the release as successful. If set to `true`, it will wait for as long as `timeout`. If set to `null` fallback on `300s` timeout.  Defaults to `false`"
  type        = bool
  default     = false
}

variable "wait_for_jobs" {
  description = "If wait is enabled, will wait until all Jobs have been completed before marking the release as successful. It will wait for as long as `timeout`. Defaults to `false`"
  type        = bool
  default     = null
}

variable "dependency_update" {
  description = "Runs helm dependency update before installing the chart. Defaults to `false`"
  type        = bool
  default     = null
}

variable "replace" {
  description = "Re-use the given name, only if that name is a deleted release which remains in the history. This is unsafe in production. Defaults to `false`"
  type        = bool
  default     = null
}

variable "lint" {
  description = "Run the helm chart linter during the plan. Defaults to `false`"
  type        = bool
  default     = null
}

variable "postrender" {
  description = "Configure a command to run after helm renders the manifest which can alter the manifest contents"
  type        = any
  default     = {}
}

variable "set" {
  description = "Value block with custom values to be merged with the values yaml"
  type        = any
  default     = []
}

variable "set_sensitive" {
  description = "Value block with custom sensitive values to be merged with the values yaml that won't be exposed in the plan's diff"
  type        = any
  default     = []
}

variable "set_irsa_names" {
  description = "Value annotations name where IRSA role ARN created by module will be assigned to the `value`"
  type        = list(string)
  default     = []
}

################################################################################
# IAM Role for Service Account(s) (IRSA)
################################################################################

variable "role_path" {
  description = "Path of IAM role"
  type        = string
  default     = "/"
}

variable "role_permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for IAM role"
  type        = string
  default     = null
}

variable "role_description" {
  description = "IAM Role description"
  type        = string
  default     = null
}

variable "role_policies" {
  description = "Policies to attach to the IAM role in `{'static_name' = 'policy_arn'}` format"
  type        = map(string)
  default     = {}
}

variable "oidc_providers" {
  description = "Map of OIDC providers where each provider map should contain the `provider_arn`, and `service_accounts`"
  type        = any
  default     = {}
}

variable "oidc_provider_arn" {
  description = "OIDC provider arn for mapping uptrace role with service account"
  type        = string
}

variable "max_session_duration" {
  description = "Maximum CLI/API session duration in seconds between 3600 and 43200"
  type        = number
  default     = null
}

variable "assume_role_condition_test" {
  description = "Name of the [IAM condition operator](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_condition_operators.html) to evaluate when assuming the role"
  type        = string
  default     = "StringEquals"
}

variable "allow_self_assume_role" {
  description = "Determines whether to allow the role to be [assume itself](https://aws.amazon.com/blogs/security/announcing-an-update-to-iam-role-trust-policy-behavior/)"
  type        = bool
  default     = false
}

################################################################################
# Helm Release Clickhouse
################################################################################

variable "clickhouse_create_release" {
  description = "Determines whether the Helm release is created"
  type        = bool
  default     = true
}

variable "clickhouse_name" {
  description = "Name of the Helm release"
  type        = string
  default     = "uptrace-clickhouse"
}

variable "clickhouse_description" {
  description = "Set release description attribute (visible in the history)"
  type        = string
  default     = "Clickhouse server"
}

variable "clickhouse_create_namespace" {
  description = "Create the namespace if it does not yet exist. Defaults to `false`"
  type        = bool
  default     = true
}

variable "clickhouse_chart" {
  description = "Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified"
  type        = string
  default     = "clickhouse"
}

variable "clickhouse_chart_version" {
  description = "Specify the exact chart version to install. If this is not specified, the latest version is installed"
  type        = string
  default     = null
}

variable "clickhouse_repository" {
  description = "Repository URL where to locate the requested chart"
  type        = string
  default     = "https://charts.bitnami.com/bitnami"
}

variable "clickhouse_values" {
  description = "List of values in raw yaml to pass to helm. Values will be merged, in order, as Helm does with multiple `-f` options"
  type        = list(string)
  default     = null
}

variable "clickhouse_timeout" {
  description = "Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks). Defaults to `300` seconds"
  type        = number
  default     = null
}

variable "clickhouse_repository_key_file" {
  description = "The repositories cert key file"
  type        = string
  default     = null
}

variable "clickhouse_repository_cert_file" {
  description = "The repositories cert file"
  type        = string
  default     = null
}

variable "clickhouse_repository_ca_file" {
  description = "The Repositories CA File"
  type        = string
  default     = null
}

variable "clickhouse_repository_username" {
  description = "Username for HTTP basic authentication against the repository"
  type        = string
  default     = null
}

variable "clickhouse_repository_password" {
  description = "Password for HTTP basic authentication against the repository"
  type        = string
  default     = null
}

variable "clickhouse_devel" {
  description = "Use chart development versions, too. Equivalent to version '>0.0.0-0'. If version is set, this is ignored"
  type        = bool
  default     = null
}

variable "clickhouse_verify" {
  description = "Verify the package before installing it. Helm uses a provenance file to verify the integrity of the chart; this must be hosted alongside the chart. For more information see the Helm Documentation. Defaults to `false`"
  type        = bool
  default     = null
}

variable "clickhouse_keyring" {
  description = "Location of public keys used for verification. Used only if verify is true. Defaults to `/.gnupg/pubring.gpg` in the location set by `home`"
  type        = string
  default     = null
}

variable "clickhouse_disable_webhooks" {
  description = "Prevent hooks from running. Defaults to `false`"
  type        = bool
  default     = null
}

variable "clickhouse_reuse_values" {
  description = "When upgrading, reuse the last release's values and merge in any overrides. If `reset_values` is specified, this is ignored. Defaults to `false`"
  type        = bool
  default     = true
}

variable "clickhouse_reset_values" {
  description = "When upgrading, reset the values to the ones built into the chart. Defaults to `false`"
  type        = bool
  default     = null
}

variable "clickhouse_force_update" {
  description = "Force resource update through delete/recreate if needed. Defaults to `false`"
  type        = bool
  default     = null
}

variable "clickhouse_recreate_pods" {
  description = "Perform pods restart during upgrade/rollback. Defaults to `false`"
  type        = bool
  default     = null
}

variable "clickhouse_cleanup_on_fail" {
  description = "Allow deletion of new resources created in this upgrade when upgrade fails. Defaults to `false`"
  type        = bool
  default     = null
}

variable "clickhouse_max_history" {
  description = "Maximum number of release versions stored per release. Defaults to `0` (no limit)"
  type        = number
  default     = null
}

variable "clickhouse_atomic" {
  description = "If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used. Defaults to `false`"
  type        = bool
  default     = null
}

variable "clickhouse_skip_crds" {
  description = "If set, no CRDs will be installed. By default, CRDs are installed if not already present. Defaults to `false`"
  type        = bool
  default     = null
}

variable "clickhouse_render_subchart_notes" {
  description = "If set, render subchart notes along with the parent. Defaults to `true`"
  type        = bool
  default     = null
}

variable "clickhouse_disable_openapi_validation" {
  description = "If set, the installation process will not validate rendered templates against the Kubernetes OpenAPI Schema. Defaults to `false`"
  type        = bool
  default     = null
}

variable "clickhouse_wait" {
  description = "Will wait until all resources are in a ready state before marking the release as successful. If set to `true`, it will wait for as long as `timeout`. If set to `null` fallback on `300s` timeout.  Defaults to `false`"
  type        = bool
  default     = false
}

variable "clickhouse_wait_for_jobs" {
  description = "If wait is enabled, will wait until all Jobs have been completed before marking the release as successful. It will wait for as long as `timeout`. Defaults to `false`"
  type        = bool
  default     = null
}

variable "clickhouse_dependency_update" {
  description = "Runs helm dependency update before installing the chart. Defaults to `false`"
  type        = bool
  default     = null
}

variable "clickhouse_replace" {
  description = "Re-use the given name, only if that name is a deleted release which remains in the history. This is unsafe in production. Defaults to `false`"
  type        = bool
  default     = null
}

variable "clickhouse_lint" {
  description = "Run the helm chart linter during the plan. Defaults to `false`"
  type        = bool
  default     = null
}

variable "clickhouse_postrender" {
  description = "Configure a command to run after helm renders the manifest which can alter the manifest contents"
  type        = any
  default     = {}
}

variable "clickhouse_set" {
  description = "Value block with custom values to be merged with the values yaml"
  type        = any
  default     = []
}

variable "clickhouse_set_sensitive" {
  description = "Value block with custom sensitive values to be merged with the values yaml that won't be exposed in the plan's diff"
  type        = any
  default     = []
}

variable "clickhouse_set_irsa_names" {
  description = "Value annotations name where IRSA role ARN created by module will be assigned to the `value`"
  type        = list(string)
  default     = []
}

################################################################################
# Helm Release Postgresql
################################################################################

variable "postgresql_create_release" {
  description = "Determines whether the Helm release is created"
  type        = bool
  default     = true
}

variable "postgresql_name" {
  description = "Name of the Helm release"
  type        = string
  default     = "uptrace-postgresql"
}

variable "postgresql_description" {
  description = "Set release description attribute (visible in the history)"
  type        = string
  default     = "Postgresql server"
}

variable "postgresql_create_namespace" {
  description = "Create the namespace if it does not yet exist. Defaults to `false`"
  type        = bool
  default     = true
}

variable "postgresql_chart" {
  description = "Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified"
  type        = string
  default     = "postgresql"
}

variable "postgresql_chart_version" {
  description = "Specify the exact chart version to install. If this is not specified, the latest version is installed"
  type        = string
  default     = null
}

variable "postgresql_repository" {
  description = "Repository URL where to locate the requested chart"
  type        = string
  default     = "https://charts.bitnami.com/bitnami"
}

variable "postgresql_values" {
  description = "List of values in raw yaml to pass to helm. Values will be merged, in order, as Helm does with multiple `-f` options"
  type        = list(string)
  default     = null
}

variable "postgresql_timeout" {
  description = "Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks). Defaults to `300` seconds"
  type        = number
  default     = null
}

variable "postgresql_repository_key_file" {
  description = "The repositories cert key file"
  type        = string
  default     = null
}

variable "postgresql_repository_cert_file" {
  description = "The repositories cert file"
  type        = string
  default     = null
}

variable "postgresql_repository_ca_file" {
  description = "The Repositories CA File"
  type        = string
  default     = null
}

variable "postgresql_repository_username" {
  description = "Username for HTTP basic authentication against the repository"
  type        = string
  default     = null
}

variable "postgresql_repository_password" {
  description = "Password for HTTP basic authentication against the repository"
  type        = string
  default     = null
}

variable "postgresql_devel" {
  description = "Use chart development versions, too. Equivalent to version '>0.0.0-0'. If version is set, this is ignored"
  type        = bool
  default     = null
}

variable "postgresql_verify" {
  description = "Verify the package before installing it. Helm uses a provenance file to verify the integrity of the chart; this must be hosted alongside the chart. For more information see the Helm Documentation. Defaults to `false`"
  type        = bool
  default     = null
}

variable "postgresql_keyring" {
  description = "Location of public keys used for verification. Used only if verify is true. Defaults to `/.gnupg/pubring.gpg` in the location set by `home`"
  type        = string
  default     = null
}

variable "postgresql_disable_webhooks" {
  description = "Prevent hooks from running. Defaults to `false`"
  type        = bool
  default     = null
}

variable "postgresql_reuse_values" {
  description = "When upgrading, reuse the last release's values and merge in any overrides. If `reset_values` is specified, this is ignored. Defaults to `false`"
  type        = bool
  default     = true
}

variable "postgresql_reset_values" {
  description = "When upgrading, reset the values to the ones built into the chart. Defaults to `false`"
  type        = bool
  default     = null
}

variable "postgresql_force_update" {
  description = "Force resource update through delete/recreate if needed. Defaults to `false`"
  type        = bool
  default     = null
}

variable "postgresql_recreate_pods" {
  description = "Perform pods restart during upgrade/rollback. Defaults to `false`"
  type        = bool
  default     = null
}

variable "postgresql_cleanup_on_fail" {
  description = "Allow deletion of new resources created in this upgrade when upgrade fails. Defaults to `false`"
  type        = bool
  default     = null
}

variable "postgresql_max_history" {
  description = "Maximum number of release versions stored per release. Defaults to `0` (no limit)"
  type        = number
  default     = null
}

variable "postgresql_atomic" {
  description = "If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used. Defaults to `false`"
  type        = bool
  default     = null
}

variable "postgresql_skip_crds" {
  description = "If set, no CRDs will be installed. By default, CRDs are installed if not already present. Defaults to `false`"
  type        = bool
  default     = null
}

variable "postgresql_render_subchart_notes" {
  description = "If set, render subchart notes along with the parent. Defaults to `true`"
  type        = bool
  default     = null
}

variable "postgresql_disable_openapi_validation" {
  description = "If set, the installation process will not validate rendered templates against the Kubernetes OpenAPI Schema. Defaults to `false`"
  type        = bool
  default     = null
}

variable "postgresql_wait" {
  description = "Will wait until all resources are in a ready state before marking the release as successful. If set to `true`, it will wait for as long as `timeout`. If set to `null` fallback on `300s` timeout.  Defaults to `false`"
  type        = bool
  default     = false
}

variable "postgresql_wait_for_jobs" {
  description = "If wait is enabled, will wait until all Jobs have been completed before marking the release as successful. It will wait for as long as `timeout`. Defaults to `false`"
  type        = bool
  default     = null
}

variable "postgresql_dependency_update" {
  description = "Runs helm dependency update before installing the chart. Defaults to `false`"
  type        = bool
  default     = null
}

variable "postgresql_replace" {
  description = "Re-use the given name, only if that name is a deleted release which remains in the history. This is unsafe in production. Defaults to `false`"
  type        = bool
  default     = null
}

variable "postgresql_lint" {
  description = "Run the helm chart linter during the plan. Defaults to `false`"
  type        = bool
  default     = null
}

variable "postgresql_postrender" {
  description = "Configure a command to run after helm renders the manifest which can alter the manifest contents"
  type        = any
  default     = {}
}

variable "postgresql_set" {
  description = "Value block with custom values to be merged with the values yaml"
  type        = any
  default     = []
}

variable "postgresql_set_sensitive" {
  description = "Value block with custom sensitive values to be merged with the values yaml that won't be exposed in the plan's diff"
  type        = any
  default     = []
}

variable "postgresql_set_irsa_names" {
  description = "Value annotations name where IRSA role ARN created by module will be assigned to the `value`"
  type        = list(string)
  default     = []
}
