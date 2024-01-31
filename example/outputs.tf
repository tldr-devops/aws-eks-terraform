output "region" {
  value = module.eks.region
}
output "vpc_id" {
  value = module.eks.vpc_id
}
output "cluster_name" {
  value = module.eks.cluster_name
}
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}
output "apisix_chart" {
  value = module.eks.apisix_chart
}
output "apisix_name" {
  value = module.eks.apisix_name
}
output "apisix_namespace" {
  value = module.eks.apisix_namespace
}
output "apisix_revision" {
  value = module.eks.apisix_revision
}
output "apisix_version" {
  value = module.eks.apisix_version
}
output "apisix_app_version" {
  value = module.eks.apisix_app_version
}
output "apisix_admin_key" {
  value = module.eks.apisix_admin_key
  sensitive = true
}
output "apisix_viewer_key" {
  value = module.eks.apisix_viewer_key
  sensitive = true
}
output "openobserve_chart" {
  value = module.eks.openobserve_chart
}
output "openobserve_name" {
  value = module.eks.openobserve_name
}
output "openobserve_namespace" {
  value = module.eks.openobserve_namespace
}
output "openobserve_revision" {
  value = module.eks.openobserve_revision
}
output "openobserve_version" {
  value = module.eks.openobserve_version
}
output "openobserve_app_version" {
  value = module.eks.openobserve_app_version
}
output "openobserve_admin_password" {
  value = module.eks.openobserve_admin_password
  sensitive = true
}
output "openobserve_collector_chart" {
  value = module.eks.openobserve_collector_chart
}
output "openobserve_collector_name" {
  value = module.eks.openobserve_collector_name
}
output "openobserve_collector_namespace" {
  value = module.eks.openobserve_collector_namespace
}
output "openobserve_collector_revision" {
  value = module.eks.openobserve_collector_revision
}
output "openobserve_collector_version" {
  value = module.eks.openobserve_collector_version
}
output "openobserve_collector_app_version" {
  value = module.eks.openobserve_collector_app_version
}
output "kubernetes_dashboard_chart" {
  value = module.eks.kubernetes_dashboard_chart
}
output "kubernetes_dashboard_name" {
  value = module.eks.kubernetes_dashboard_name
}
output "kubernetes_dashboard_namespace" {
  value = module.eks.kubernetes_dashboard_namespace
}
output "kubernetes_dashboard_revision" {
  value = module.eks.kubernetes_dashboard_revision
}
output "kubernetes_dashboard_version" {
  value = module.eks.kubernetes_dashboard_version
}
output "kubernetes_dashboard_app_version" {
  value = module.eks.kubernetes_dashboard_app_version
}
