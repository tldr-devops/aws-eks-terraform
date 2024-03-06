################################################################################
# Helm Release
################################################################################

output "chart" {
  description = "The name of the chart"
  value       = {
    victoriametrics           = try(module.victoriametrics.chart, null)
    prometheus_operator_crds  = try(module.prometheus_operator_crds.chart, null)
  }
}

output "name" {
  description = "Name is the name of the release"
  value       = {
    victoriametrics           = try(module.victoriametrics.name, null)
    prometheus_operator_crds  = try(module.prometheus_operator_crds.name, null)
  }
}

output "namespace" {
  description = "Name of Kubernetes namespace"
  value       = {
    victoriametrics           = try(module.victoriametrics.namespace, null)
    prometheus_operator_crds  = try(module.prometheus_operator_crds.namespace, null)
  }
}

output "revision" {
  description = "Version is an int32 which represents the version of the release"
  value       = {
    victoriametrics           = try(module.victoriametrics.revision, null)
    prometheus_operator_crds  = try(module.prometheus_operator_crds.revision, null)
  }
}

output "version" {
  description = "A SemVer 2 conformant version string of the chart"
  value       = {
    victoriametrics           = try(module.victoriametrics.version, null)
    prometheus_operator_crds  = try(module.prometheus_operator_crds.version, null)
  }
}

output "app_version" {
  description = "The version number of the application being deployed"
  value       = {
    victoriametrics           = try(module.victoriametrics.app_version, null)
    prometheus_operator_crds  = try(module.prometheus_operator_crds.app_version, null)
  }
}

output "values" {
  description = "The compounded values from `values` and `set*` attributes"
  value       = {
    victoriametrics           = try(module.victoriametrics.values, [])
    prometheus_operator_crds  = try(module.prometheus_operator_crds.values, [])
  }
}
