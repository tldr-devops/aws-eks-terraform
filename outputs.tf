output "eks" {
  value       = module.eks
}

output "aws_efs_csi_driver" {
  value       = module.addons.aws_efs_csi_driver
}

output "aws_node_termination_handler" {
  value       = module.addons.aws_node_termination_handler
}

output "cert_manager" {
  value       = module.addons.cert_manager
}

output "cluster_autoscaler" {
  value       = module.addons.cluster_autoscaler
}

output "eks_addons" {
  value       = module.addons.eks_addons
}

output "metrics_server" {
  value       = module.addons.metrics_server
}

output "vpa" {
  value       = module.addons.vpa
}

output "apisix" {
  value       = try(module.ingress_apisix, null)
}

output "nginx" {
  value       = try(module.ingress_nginx, null)
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

output "victoriametrics" {
  value       = try(module.victoriametrics, null)
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

output "vector_agent" {
  value       = try(module.vector_agent, null)
}

output "kubernetes_dashboard" {
  value       = try(module.kubernetes_dashboard, null)
}
