provider "aws" {
  region = "us-east-2"
}

locals {
  cluster_name = "test"

  vpc_name = "eks_${local.cluster_name}"
  azs = data.aws_availability_zones.available.names
  cidr = "10.0.0.0/16"
  public_subnet_suffix = "public"
  private_subnet_suffix = "private"

  # you can limit number of used availability zones, min 2 is required by eks
  number_of_multi_az = length(local.azs)

  # Limit number of availability zones in generating from templates.
  # Could be from 0 and up to ${number_of_multi_az}
  self_managed_node_group_number_of_multi_az = 2
  eks_managed_node_group_number_of_multi_az = 2
  fargate_profile_number_of_multi_az = 2

  # this module will generate next fargate profiles for each selected availability zones:
  # kube-system, cert-manager, external-dns, external-secrets, vpa
  # however, you can add yours fargate profiles or host managed groups
  # via template for generating in each selected availability zone
  fargate_profile_templates_for_multi_az = {
    default = {}
  }
  # or in all cluster networks and availability zones
   eks_managed_node_groups = {}
#     management = {
#       min_size     = 0
#       desired_size = 0
#       labels = {
#         "node.kubernetes.io/purpose" = "management"
#       }
#       taints = {
#         purpose = {
#           key    = "node.kubernetes.io/purpose"
#           value  = "management"
#           effect = "NO_SCHEDULE"
#         }
#       }
#     }
#   }

  tags = {
    Environment = "test"
    EKS = local.cluster_name
    Terraform = "true"
  }

}

data "aws_availability_zones" "available" {}

# https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.vpc_name
  cidr = local.cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.cidr, 8, k*2)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.cidr, 8, k*2+1)]

  public_subnet_suffix = local.public_subnet_suffix
  private_subnet_suffix = local.private_subnet_suffix

  enable_nat_gateway = true
  single_nat_gateway = false
  one_nat_gateway_per_az = true

  enable_vpn_gateway = false

  tags = local.tags
}

module "eks" {
  source = "../"

  vpc_id = module.vpc.vpc_id
  cluster_name = local.cluster_name
  number_of_multi_az = local.number_of_multi_az
  self_managed_node_group_number_of_multi_az = local.self_managed_node_group_number_of_multi_az
  eks_managed_node_group_number_of_multi_az = local.eks_managed_node_group_number_of_multi_az
  fargate_profile_number_of_multi_az = local.fargate_profile_number_of_multi_az
  fargate_profile_templates_for_multi_az = local.fargate_profile_templates_for_multi_az
  eks_managed_node_groups = local.eks_managed_node_groups
  tags = local.tags
}
