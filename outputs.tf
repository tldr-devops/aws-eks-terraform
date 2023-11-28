output "region" {
  value       = data.aws_region.current.name
  description = "The AWS region"
}

output "vpc_id" {
  value       = data.aws_vpc.target.id
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
