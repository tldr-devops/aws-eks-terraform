output "eks" {
  value       = module.eks
}

output "addons" {
  value       = module.addons
}

output "apisix" {
  value       = try(module.ingress_apisix, null)
}

output "victoriametrics_operator" {
  value       = try(module.victoriametrics_operator, null)
}

output "opentelemetry_operator" {
  value       = try(module.opentelemetry_operator, null)
}

output "clickhouse_operator" {
  value       = try(module.clickhouse_operator, null)
}

output "grafana_operator" {
  value       = try(module.grafana_operator, null)
}

output "grafana" {
  value       = try(module.grafana, null)
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
