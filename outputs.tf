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
  description = "The name of the chart"
  value       = try(module.ingress_apisix.chart, null)
}

output "apisix_name" {
  description = "Name is the name of the release"
  value       = try(module.ingress_apisix.name, null)
}

output "apisix_namespace" {
  description = "Name of Kubernetes namespace"
  value       = try(module.ingress_apisix.namespace, null)
}

output "apisix_revision" {
  description = "Version is an int32 which represents the version of the release"
  value       = try(module.ingress_apisix.revision, null)
}

output "apisix_version" {
  description = "A SemVer 2 conformant version string of the chart"
  value       = try(module.ingress_apisix.version, null)
}

output "apisix_app_version" {
  description = "The version number of the application being deployed"
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
