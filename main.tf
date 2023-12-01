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

locals {
  cluster_addons = try(var.cluster_addons, {
    coredns = {
      most_recent = true
      configuration_values = jsonencode({
        nodeSelector = {
          "kubernetes.io/os" = "linux"
          "node.kubernetes.io/purpose" = "management"
        }
      })
    }
    kube-proxy = {
      most_recent = true
      configuration_values = jsonencode({
        nodeSelector = {
          "kubernetes.io/os" = "linux"
          "node.kubernetes.io/purpose" = "management"
        }
      })
    }
    vpc-cni = {
      most_recent = true
      configuration_values = jsonencode({
        nodeSelector = {
          "kubernetes.io/os" = "linux"
          "node.kubernetes.io/purpose" = "management"
        }
      })
    }
    aws-ebs-csi-driver = {
      most_recent = true
      configuration_values = jsonencode({
        nodeSelector = {
          "kubernetes.io/os" = "linux"
          "node.kubernetes.io/purpose" = "management"
        }
      })
    }
    snapshot-controller = {
      most_recent = true
      configuration_values = jsonencode({
        nodeSelector = {
          "kubernetes.io/os" = "linux"
          "node.kubernetes.io/purpose" = "management"
        }
      })
    }
  })

  universal_addon_config = {
    values = [templatefile("${path.module}/universal_values.yaml", {})]
  }
  aws_efs_csi_driver_config = try(var.aws_efs_csi_driver_config, local.universal_addon_config)
  aws_node_termination_handler_config = try(var.aws_node_termination_handler_config, local.universal_addon_config)
  cert_manager_config = try(var.cert_manager_config, local.universal_addon_config)
  cluster_autoscaler_config = try(var.cluster_autoscaler_config, local.universal_addon_config)
  metrics_server_config = try(var.metrics_server_config, local.universal_addon_config)
  vpa_config = try(var.vpa_config, local.universal_addon_config)
}

module "eks" {
  source = "./modules/eks"

  vpc_id = var.vpc_id
  cluster_name = var.cluster_name
  cluster_version = var.cluster_version
  # cluster_addons = var.cluster_addons
  self_managed_node_group_defaults = var.self_managed_node_group_defaults
  eks_managed_node_group_defaults = var.eks_managed_node_group_defaults
  fargate_profile_defaults = var.fargate_profile_defaults
  group_defaults = var.group_defaults
  self_managed_node_groups = var.self_managed_node_groups
  eks_managed_node_groups = var.eks_managed_node_groups
  fargate_profiles = var.fargate_profiles
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
