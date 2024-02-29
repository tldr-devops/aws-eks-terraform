output "eks" {
  value       = module.eks
}

output "addons" {
  value       = module.addons
}

output "apisix" {
  value       = try(module.ingress_apisix, null)
}

output "opentelemetry_operator" {
  value       = try(module.opentelemetry_operator, null)
}

output "clickhouse_operator" {
  value       = try(module.clickhouse_operator, null)
}

output "uptrace" {
  value       = try(module.uptrace, null)
}

output "qryn" {
  value       = try(module.qryn, null)
}

output "openobserve" {
  value       = try(module.openobserve, null)
}

output "openobserve_collector" {
  value       = try(module.openobserve_collector, null)
}

output "kubernetes_dashboard" {
  value       = try(module.kubernetes_dashboard, null)
}
