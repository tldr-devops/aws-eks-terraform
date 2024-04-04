################################################################################
# Helm Release
################################################################################

output "chart" {
  description = "The name of the chart"
  value       = {
    stack = try(module.victoriametrics.chart, null)
    auth  = try(module.auth.chart, null)
  }
}

output "name" {
  description = "Name is the name of the release"
  value       = {
    stack = try(module.victoriametrics.name, null)
    auth  = try(module.auth.name, null)
  }
}

output "namespace" {
  description = "Name of Kubernetes namespace"
  value       = {
    stack = try(module.victoriametrics.namespace, null)
    auth  = try(module.auth.namespace, null)
  }
}

output "revision" {
  description = "Version is an int32 which represents the version of the release"
  value       = {
    stack = try(module.victoriametrics.revision, null)
    auth  = try(module.auth.revision, null)
  }
}

output "version" {
  description = "A SemVer 2 conformant version string of the chart"
  value       = {
    stack = try(module.victoriametrics.version, null)
    auth  = try(module.auth.version, null)
  }
}

output "app_version" {
  description = "The version number of the application being deployed"
  value       = {
    stack = try(module.victoriametrics.app_version, null)
    auth  = try(module.auth.app_version, null)
  }
}

# output "values" {
#   description = "The compounded values from `values` and `set*` attributes"
#   value       = {
#     stack = try(module.victoriametrics.values, [])
#     auth  = try(module.auth.values, null)
#   }
# }

################################################################################
# Grafana
################################################################################

output "grafana_admin_password" {
  description = "Grafana admin password"
  value       = local.grafana_admin_password
  sensitive   = true
}

output "grafana_admin_user" {
  description = "Grafana admin user"
  value       = var.grafana_admin_user
}

################################################################################
# VM Auth
################################################################################

output "auth_vmagent_rw_user" {
  description = "VM Agent read write user"
  value       = local.auth_vmagent_rw_user
}

output "auth_vmagent_rw_password" {
  description = "VM Agent read write password"
  value       = local.auth_vmagent_rw_password
  sensitive   = true
}

output "auth_vmsingle_user" {
  description = "VM Single user"
  value       = local.auth_vmsingle_user
}

output "auth_vmsingle_password" {
  description = "VM Single password"
  value       = local.auth_vmsingle_password
  sensitive   = true
}

output "auth_vmselect_user" {
  description = "VM Select user"
  value       = local.auth_vmselect_user
}

output "auth_vmselect_password" {
  description = "VM Select password"
  value       = local.auth_vmselect_password
  sensitive   = true
}

output "auth_alertmanager_user" {
  description = "VM Alertmanager user"
  value       = local.auth_alertmanager_user
}

output "auth_alertmanager_password" {
  description = "VM Alertmanager password"
  value       = local.auth_alertmanager_password
  sensitive   = true
}

output "auth_vmalert_user" {
  description = "VM Alert user"
  value       = local.auth_vmalert_user
}

output "auth_vmalert_password" {
  description = "VM Alert password"
  value       = local.auth_vmalert_password
  sensitive   = true
}
