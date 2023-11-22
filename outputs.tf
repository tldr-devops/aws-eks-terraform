output "region" {
  value       = data.aws_region.current.name
  description = "The AWS region"
}

output "vpc_id" {
  value       = data.aws_vpc.target.id
  description = "The ID of the target VPC"
}

output "cluster" {
  value       = var.cluster_name
  description = "The name of the EKS"
}
