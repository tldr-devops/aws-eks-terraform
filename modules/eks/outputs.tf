output "region" {
  value       = data.aws_region.current.name
  description = "The AWS region"
}

output "vpc_id" {
  value       = data.aws_vpc.target.id
  description = "The ID of the target VPC"
}

output "cloudwatch_log_group_arn" {
  value       = module.eks.cloudwatch_log_group_arn
  description = "Arn of cloudwatch log group created"
}

output "cloudwatch_log_group_name" {
  value       = module.eks.cloudwatch_log_group_name
  description = "Name of cloudwatch log group created"
}

output "cluster_addons" {
  value       = module.eks.cluster_addons
  description = "Map of attribute maps for all EKS cluster addons enabled"
}

output "cluster_arn" {
  value       = module.eks.cluster_arn
  description = "The Amazon Resource Name (ARN) of the cluster"
}

output "cluster_certificate_authority_data" {
  value       = module.eks.cluster_certificate_authority_data
  description = "Base64 encoded certificate data required to communicate with the cluster"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "Endpoint for your Kubernetes API server"
}

output "cluster_iam_role_arn" {
  value       = module.eks.cluster_iam_role_arn
  description = "IAM role ARN of the EKS cluster"
}

output "cluster_iam_role_name" {
  value       = module.eks.cluster_iam_role_name
  description = "IAM role name of the EKS cluster"
}

output "cluster_iam_role_unique_id" {
  value       = module.eks.cluster_iam_role_unique_id
  description = "Stable and unique string identifying the IAM role"
}

output "cluster_id" {
  value       = module.eks.cluster_id
  description = "The ID of the EKS cluster. Note: currently a value is returned only for local EKS clusters created on Outposts"
}

output "cluster_identity_providers" {
  value       = module.eks.cluster_identity_providers
  description = "Map of attribute maps for all EKS identity providers enabled"
}

output "cluster_name" {
  value       = module.eks.cluster_name
  description = "The name of the EKS cluster"
}

output "cluster_oidc_issuer_url" {
  value       = module.eks.cluster_oidc_issuer_url
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
}

output "cluster_platform_version" {
  value       = module.eks.cluster_platform_version
  description = "Platform version for the cluster"
}

output "cluster_primary_security_group_id" {
  value       = module.eks.cluster_primary_security_group_id
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
}

output "cluster_security_group_arn" {
  value       = module.eks.cluster_security_group_arn
  description = "Amazon Resource Name (ARN) of the cluster security group"
}

output "cluster_security_group_id" {
  value       = module.eks.cluster_security_group_id
  description = "ID of the cluster security group"
}

output "cluster_status" {
  value       = module.eks.cluster_status
  description = "Status of the EKS cluster. One of CREATING, ACTIVE, DELETING, FAILED"
}

output "cluster_tls_certificate_sha1_fingerprint" {
  value       = module.eks.cluster_tls_certificate_sha1_fingerprint
  description = "The SHA1 fingerprint of the public key of the cluster's certificate"
}

output "cluster_version" {
  value       = module.eks.cluster_version
  description = "The Kubernetes version for the cluster"
}

output "eks_managed_node_groups" {
  value       = module.eks.eks_managed_node_groups
  description = "Map of attribute maps for all EKS managed node groups created"
}

output "eks_managed_node_groups_autoscaling_group_names" {
  value       = module.eks.eks_managed_node_groups_autoscaling_group_names
  description = "List of the autoscaling group names created by EKS managed node groups"
}

output "fargate_profiles" {
  value       = module.eks.fargate_profiles
  description = "Map of attribute maps for all EKS Fargate Profiles created"
}

output "kms_key_arn" {
  value       = module.eks.kms_key_arn
  description = "The Amazon Resource Name (ARN) of the key"
}

output "kms_key_id" {
  value       = module.eks.kms_key_id
  description = "The globally unique identifier for the key"
}

output "kms_key_policy" {
  value       = module.eks.kms_key_policy
  description = "The IAM resource policy set on the key"
}

output "node_security_group_arn" {
  value       = module.eks.node_security_group_arn
  description = "Amazon Resource Name (ARN) of the node shared security group"
}

output "node_security_group_id" {
  value       = module.eks.node_security_group_id
  description = "ID of the node shared security group"
}

output "oidc_provider" {
  value       = module.eks.oidc_provider
  description = "The OpenID Connect identity provider (issuer URL without leading https://)"
}

output "oidc_provider_arn" {
  value       = module.eks.oidc_provider_arn
  description = "The ARN of the OIDC Provider if enable_irsa = true"
}

output "self_managed_node_groups" {
  value       = module.eks.self_managed_node_groups
  description = "Map of attribute maps for all self managed node groups created"
}

output "self_managed_node_groups_autoscaling_group_names" {
  value       = module.eks.self_managed_node_groups_autoscaling_group_names
  description = "List of the autoscaling group names created by self-managed node groups"
}
