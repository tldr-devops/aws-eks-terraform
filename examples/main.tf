provider "aws" {
  region = "us-east-2"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_availability_zones" "this" {}

data "aws_subnets" "this" {
  count = length(data.aws_availability_zones.this.names)

  filter {
    name   = "availability-zone"
    values = [data.aws_availability_zones.this.names[count.index]]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

locals {
  subnets_az = [
    for i, name in data.aws_availability_zones.this.names: {
      zone    = name
      subnets = data.aws_subnets.this[i].ids
    }
  ]

  cluster_name = "test"

  tags = {
    Environment = "test"
    EKS = local.cluster_name
    Terraform = "true"
  }

#   eks_managed_node_groups = {
#     management_1 = {
#       name = "management_" + local.subnets_az[0].zone
#       subnet_ids = local.subnets_az[0].subnets
#       min_size     = 1
#       desired_size = 1
#       labels = {
#         node.kubernetes.io/purpose = "management"
#       }
#       taints = {
#         purpose = {
#           key    = "node.kubernetes.io/purpose"
#           value  = "management"
#           effect = "NO_SCHEDULE"
#         }
#       }
#     }
#     management_2 = {
#       name = "management_" + local.subnets_az[1].zone
#       subnet_ids = local.subnets_az[1].subnets
#       min_size     = 1
#       desired_size = 1
#       labels = {
#         node.kubernetes.io/purpose = "management"
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

  fargate_namespaces = [
    "kube-system",
    "cert-manager",
    "external-dns",
    "external-secrets",
    "vpa"
  ]

  fargate_profiles = merge([
    for namespace in local.fargate_namespaces : {
      for az in local.subnets_az : "${namespace}_${az.zone}" => {
        name       = "${namespace}_${az.zone}"
        subnet_ids = az.subnets
        selectors  = [{ namespace = namespace }]
        tags = local.tags
      }
    }
  ]...)
}

module "eks" {
  source = "../"

  cluster_name = local.cluster_name
  fargate_profiles = local.fargate_profiles
  tags = local.tags
}
