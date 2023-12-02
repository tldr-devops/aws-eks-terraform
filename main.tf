provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

# provider "kubectl" {
#   apply_retry_count      = 5
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#   load_config_file       = false
# 
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     # This requires the awscli to be installed locally where Terraform is executed
#     args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
#   }
# }

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
    values = [local.vpc_id]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

locals {
  vpc_id = coalesce(var.vpc_id, data.aws_vpc.default.id)

  subnets_by_az = coalesce(
    var.subnets_by_az,
    [
      for i, name in data.aws_availability_zones.this.names: {
        zone    = name
        subnets = data.aws_subnets.this[i].ids
      }
    ]
  )

  number_of_multi_az = min(var.number_of_multi_az, length(local.subnets_by_az))

  # I don't think that we need more availability zones in node groups than in control plane
  self_managed_node_group_number_of_multi_az = min(var.self_managed_node_group_number_of_multi_az, local.number_of_multi_az)
  eks_managed_node_group_number_of_multi_az = min(var.eks_managed_node_group_number_of_multi_az, local.number_of_multi_az)
  fargate_profile_number_of_multi_az = min(var.fargate_profile_number_of_multi_az, local.number_of_multi_az)

  subnets = flatten([
    for az in slice(local.subnets_by_az, 0, local.number_of_multi_az):
      az.subnets
  ])

  # place for defaults
  self_managed_node_group_templates_for_multi_az = merge(
    {},
    var.self_managed_node_group_templates_for_multi_az
  )

  self_managed_node_groups_multi_az_list = flatten([
    for key, value in local.self_managed_node_group_templates_for_multi_az: [
      for az in slice(local.subnets_by_az, 0, local.self_managed_node_group_number_of_multi_az): {
        name       = "${key}_${az.zone}"
        subnet_ids = az.subnets
        merge_value = value
      }
    ]
  ])

  self_managed_node_groups_multi_az = {
    for i in local.self_managed_node_groups_multi_az_list: i.name => merge(i.merge_value, i)
  }

  self_managed_node_groups = merge(local.self_managed_node_groups_multi_az, var.self_managed_node_groups)

  # place for defaults
  eks_managed_node_group_templates_for_multi_az = merge(
    {},
    var.eks_managed_node_group_templates_for_multi_az
  )

  eks_managed_node_groups_multi_az_list = flatten([
    for key, value in local.eks_managed_node_group_templates_for_multi_az: [
      for az in slice(local.subnets_by_az, 0, local.eks_managed_node_group_number_of_multi_az): {
        name       = "${key}_${az.zone}"
        subnet_ids = az.subnets
        merge_value = value
      }
    ]
  ])

  eks_managed_node_groups_multi_az = {
    for i in local.eks_managed_node_groups_multi_az_list: i.name => merge(i.merge_value, i)
  }

  eks_managed_node_groups = merge(local.eks_managed_node_groups_multi_az, var.eks_managed_node_groups)

  # https://docs.aws.amazon.com/eks/latest/userguide/fargate-profile.html
  # https://aws.amazon.com/ru/blogs/containers/monitoring-amazon-eks-on-aws-fargate-using-prometheus-and-grafana/
  # https://docs.aws.amazon.com/eks/latest/userguide/monitoring-fargate-usage.html

  # Amazon EKS and Fargate spread Pods across each of the subnets that's defined
  # in the Fargate profile. However, you might end up with an uneven spread.
  # If you must have an even spread, use two Fargate profiles. Even spread
  # is important in scenarios where you want to deploy two replicas and don't
  # want any downtime. We recommend that each profile has only one subnet.

  fargate_profile_templates_for_multi_az = merge(
    {
      kube-system = {}
      cert-manager = {}
      external-dns = {}
      external-secrets = {}
      vpa = {}
    },
    var.fargate_profile_templates_for_multi_az
  )

  fargate_profiles_multi_az_list = flatten([
    for key, value in local.fargate_profile_templates_for_multi_az: [
      for az in slice(local.subnets_by_az, 0, local.fargate_profile_number_of_multi_az): {
        name       = "${key}_${az.zone}"
        subnet_ids = az.subnets
        selectors = try(
          value.selectors,
          [{namespace = key}]
        )
        tags = merge(try(value.tags, {}), var.tags)
        merge_value = value
      }
    ]
  ])

  fargate_profiles_multi_az = {
    for i in local.fargate_profiles_multi_az_list: i.name => merge(i.merge_value, i)
  }

  fargate_profiles = merge(local.fargate_profiles_multi_az, var.fargate_profiles)

  universal_cluster_addon_config = {
    most_recent = true
    configuration_values = jsonencode({
      nodeSelector = {
        "kubernetes.io/os" = "linux"
        "node.kubernetes.io/purpose" = "management"
      }
    })
  }

  cluster_addons = merge(
    {
      coredns = local.universal_cluster_addon_config
      kube-proxy = local.universal_cluster_addon_config
      vpc-cni = local.universal_cluster_addon_config
      aws-ebs-csi-driver = local.universal_cluster_addon_config
      snapshot-controller = local.universal_cluster_addon_config
    },
    var.cluster_addons
  )

  universal_addon_config = {
    values = [templatefile("${path.module}/universal_values.yaml", {})]
  }

  aws_efs_csi_driver_config = merge(local.universal_addon_config, var.aws_efs_csi_driver_config)

  aws_node_termination_handler_config = merge(local.universal_addon_config, var.aws_node_termination_handler_config)

  cert_manager_config = merge(local.universal_addon_config, var.cert_manager_config)

  cluster_autoscaler_config = merge(local.universal_addon_config, var.cluster_autoscaler_config)

  metrics_server_config = merge(local.universal_addon_config, var.metrics_server_config)

  vpa_config = merge(local.universal_addon_config, var.vpa_config)

}

module "eks" {
  source = "./modules/eks"

  vpc_id = local.vpc_id
  subnet_ids = local.subnets
  cluster_name = var.cluster_name
  cluster_version = var.cluster_version
  cluster_addons = {}
  self_managed_node_group_defaults = var.self_managed_node_group_defaults
  eks_managed_node_group_defaults = var.eks_managed_node_group_defaults
  fargate_profile_defaults = var.fargate_profile_defaults
  group_defaults = var.group_defaults
  self_managed_node_groups = local.self_managed_node_groups
  eks_managed_node_groups = local.eks_managed_node_groups
  fargate_profiles = local.fargate_profiles
  admin_iam_roles = var.admin_iam_roles
  admin_iam_users = var.admin_iam_users
  eks_iam_roles = var.eks_iam_roles
  tags = var.tags
}

module "addons" {
  source = "aws-ia/eks-blueprints-addons/aws"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = local.cluster_addons

  # https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/0e9d6c9b7115ecf0404c377c9c2529bffa56d10d/docs/addons/aws-efs-csi-driver.md
  enable_aws_efs_csi_driver = var.enable_aws_efs_csi_driver
  aws_efs_csi_driver = local.aws_efs_csi_driver_config

  # https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/0e9d6c9b7115ecf0404c377c9c2529bffa56d10d/docs/addons/aws-node-termination-handler.md
  enable_aws_node_termination_handler = var.enable_aws_node_termination_handler
  aws_node_termination_handler = local.aws_node_termination_handler_config

  # https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/0e9d6c9b7115ecf0404c377c9c2529bffa56d10d/docs/addons/cert-manager.md
  enable_cert_manager = var.enable_cert_manager
  cert_manager = local.cert_manager_config

  # https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/0e9d6c9b7115ecf0404c377c9c2529bffa56d10d/docs/addons/cluster-autoscaler.md
  enable_cluster_autoscaler = var.enable_cluster_autoscaler
  cluster_autoscaler = local.cluster_autoscaler_config

  # https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/0e9d6c9b7115ecf0404c377c9c2529bffa56d10d/docs/addons/metrics-server.md
  enable_metrics_server = var.enable_metrics_server
  metrics_server = local.metrics_server_config

  # https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/0e9d6c9b7115ecf0404c377c9c2529bffa56d10d/docs/addons/vertical-pod-autoscaler.md
  enable_vpa = var.enable_vpa
  vpa = local.vpa_config

  tags = var.tags
}

# ingress
# metrics
# logs
