output "region" {
  value       = module.eks.region
  description = "The AWS region"
}

output "vpc_id" {
  value       = module.eks.vpc_id
  description = "The ID of the target VPC"
}

output "cluster_name" {
  value       = module.eks.cluster_name
  description = "The name of the EKS"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "Endpoint for your Kubernetes API server"
}

output "cluster_certificate_authority_data" {
  value       = module.eks.cluster_certificate_authority_data
  description = "Base64 encoded certificate data required to communicate with the cluster"
}

output "apisix_chart" {
  description = "The name of the apisix chart"
  value       = try(module.ingress_apisix.chart, null)
}

output "apisix_name" {
  description = "Name is the name of the apisix release"
  value       = try(module.ingress_apisix.name, null)
}

output "apisix_namespace" {
  description = "Name of apisix namespace"
  value       = try(module.ingress_apisix.namespace, null)
}

output "apisix_revision" {
  description = "Version is an int32 which represents the version of the apisix release"
  value       = try(module.ingress_apisix.revision, null)
}

output "apisix_version" {
  description = "A SemVer 2 conformant version string of the apisix chart"
  value       = try(module.ingress_apisix.version, null)
}

output "apisix_app_version" {
  description = "The version number of the apisix being deployed"
  value       = try(module.ingress_apisix.app_version, null)
}

output "apisix_admin_key" {
  description = "The apisix admin key"
  value       = try(module.ingress_apisix.apisix_admin_key, null)
}

output "apisix_viewer_key" {
  description = "The apisix viewer key"
  value       = try(module.ingress_apisix.apisix_viewer_key, null)
}

output "openobserve_chart" {
  description = "The name of the openobserve chart"
  value       = try(module.openobserve.chart, null)
}

output "openobserve_name" {
  description = "Name is the name of the openobserve release"
  value       = try(module.openobserve.name, null)
}

output "openobserve_namespace" {
  description = "Name of openobserve namespace"
  value       = try(module.openobserve.namespace, null)
}

output "openobserve_revision" {
  description = "Version is an int32 which represents the version of the openobserve release"
  value       = try(module.openobserve.revision, null)
}

output "openobserve_version" {
  description = "A SemVer 2 conformant version string of the openobserve chart"
  value       = try(module.openobserve.version, null)
}

output "openobserve_app_version" {
  description = "The version number of the openobserve being deployed"
  value       = try(module.openobserve.app_version, null)
}

output "openobserve_admin_password" {
  description = "The openobserve admin password"
  value       = try(module.openobserve.zo_root_user_password, null)
}
