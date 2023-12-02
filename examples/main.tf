provider "aws" {
  region = "us-east-2"
}

locals {
  cluster_name = "test"

  # use only one availability zone for reduce cross zones traffic cost.
  # would be set to amount of availability zones in case when value is more that that number
  number_of_multi_az = 1

  # could be also set separately for generated from templates
  # groups and fargate profiles. Can't be more than number_of_multi_az
  self_managed_node_group_number_of_multi_az = 1
  eks_managed_node_group_number_of_multi_az = 1
  fargate_profile_number_of_multi_az = 1

  # this module will generate next fargate profiles for each selected availability zones:
  # kube-system, cert-manager, external-dns, external-secrets, vpa
  # however, you can add yours fargate profiles or host managed groups
  # via template for generating in each selected availability zone
  fargate_profile_templates_for_multi_az = {
    default = {}
  }
  # or in all cluster networks and availability zones
  eks_managed_node_groups = {
    management = {
      min_size     = 0
      desired_size = 0
      labels = {
        "node.kubernetes.io/purpose" = "management"
      }
      taints = {
        purpose = {
          key    = "node.kubernetes.io/purpose"
          value  = "management"
          effect = "NO_SCHEDULE"
        }
      }
    }
  }

  tags = {
    Environment = "test"
    EKS = local.cluster_name
    Terraform = "true"
  }

}

module "eks" {
  source = "../"

  cluster_name = local.cluster_name
  number_of_multi_az = local.number_of_multi_az
  self_managed_node_group_number_of_multi_az = local.self_managed_node_group_number_of_multi_az
  eks_managed_node_group_number_of_multi_az = local.eks_managed_node_group_number_of_multi_az
  fargate_profile_number_of_multi_az = local.fargate_profile_number_of_multi_az
  tags = local.tags
}
