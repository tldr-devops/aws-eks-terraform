provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  # This requires the awscli to be installed locally where Terraform is executed
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_vpc" "target" {
  id = local.vpc_id
}

data "aws_subnets" "vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

locals {
  vpc_id = coalesce(var.vpc_id, data.aws_vpc.default.id)

  subnet_ids = coalesce(var.subnet_ids, data.aws_subnets.vpc_subnets.ids)

  self_managed_node_group_defaults = merge(var.group_defaults, var.self_managed_node_group_defaults)
  eks_managed_node_group_defaults = merge(var.group_defaults, var.eks_managed_node_group_defaults)
  fargate_profile_defaults = merge(var.group_defaults, var.fargate_profile_defaults)

  aws_auth_users = [
    for u in var.admin_iam_users : {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${u}"
      username = u
      groups   = ["system:masters"]
    }
  ]

  aws_auth_roles = [
    for u in var.admin_iam_roles : {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${u}"
      username = u
      groups   = ["system:masters"]
    }
  ]
}

################################################################################
# EKS
# Full example https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/complete/main.tf
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  # https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html
  cluster_version = var.cluster_version

  cluster_endpoint_public_access  = true
  enable_irsa = true

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon
  cluster_addons = var.cluster_addons

  vpc_id                   = local.vpc_id
  subnet_ids               = local.subnet_ids
  # control_plane_subnet_ids = data.aws_subnets.vpc_subnets.ids

  self_managed_node_group_defaults = local.self_managed_node_group_defaults
  eks_managed_node_group_defaults = local.eks_managed_node_group_defaults
  fargate_profile_defaults = local.fargate_profile_defaults

  self_managed_node_groups = var.self_managed_node_groups
  eks_managed_node_groups = var.eks_managed_node_groups
  fargate_profiles = var.fargate_profiles

  # aws-auth configmap
  manage_aws_auth_configmap = false
  create_aws_auth_configmap = false

  # https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  cloudwatch_log_group_retention_in_days = 30 # default is 90

  aws_auth_roles = local.aws_auth_roles
  aws_auth_users = local.aws_auth_users
  aws_auth_accounts = [
    data.aws_caller_identity.current.account_id
  ]

  tags = var.tags
}

resource "kubernetes_service_account" "accounts" {
  count = length(var.eks_iam_roles)

  metadata {
    name      = var.eks_iam_roles[count.index].role_name
    namespace = var.eks_iam_roles[count.index].role_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = var.eks_iam_roles[count.index].role_arn
    }
  }
  automount_service_account_token = true
}

module "iam_eks_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  count = length(var.eks_iam_roles)

  role_name = var.eks_iam_roles[count.index].role_name

  role_policy_arns = var.eks_iam_roles[count.index].role_policy_arns

  oidc_providers = {
    default = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.eks_iam_roles[count.index].role_namespace}:${var.eks_iam_roles[count.index].role_name}"]
    }
  }
}

resource "null_resource" "kubectl" {
    provisioner "local-exec" {
        command = "aws eks --region ${data.aws_region.current.name} update-kubeconfig --name ${module.eks.cluster_name} --kubeconfig ~/.kube/eks-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-${module.eks.cluster_name}"
    }
}
