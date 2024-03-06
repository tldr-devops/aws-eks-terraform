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

data "aws_subnets" "private" {
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

  dynamic "filter" {
    for_each = var.private_subnets_filters
    content {
      name   = filter.value.name
      values = filter.value.values
    }
  }
}

data "aws_subnets" "available" {
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

  private_subnets_by_az = [
    for i, name in data.aws_availability_zones.this.names: {
      zone    = name
      subnets = data.aws_subnets.private[i].ids
    } if length(data.aws_subnets.private[i].ids) > 0
  ]

  available_subnets_by_az = [
    for i, name in data.aws_availability_zones.this.names: {
      zone    = name
      subnets = data.aws_subnets.available[i].ids
    } if length(data.aws_subnets.available[i].ids) > 0
  ]

  subnets_by_az = coalescelist(
    var.subnets_by_az,
    local.private_subnets_by_az,
    local.available_subnets_by_az
  )

  number_of_multi_az = min(var.number_of_multi_az, length(local.subnets_by_az))

  # I don't think that we need more availability zones in node groups than in control plane
  self_managed_node_group_number_of_multi_az = min(
    var.self_managed_node_group_number_of_multi_az,
    local.number_of_multi_az
  )
  eks_managed_node_group_number_of_multi_az = min(
    var.eks_managed_node_group_number_of_multi_az,
    local.number_of_multi_az
  )
  fargate_profile_number_of_multi_az = min(
    var.fargate_profile_number_of_multi_az,
    local.number_of_multi_az,
    length(local.private_subnets_by_az) # fargate works only in private subnets
  )

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
      for az in slice(local.subnets_by_az, 0, local.self_managed_node_group_number_of_multi_az): merge(
        value,
        {
          key         = key
          name        = "${key}_${az.zone}"
          subnet_ids  = az.subnets
        }
      )
    ]
  ])

  self_managed_node_groups_multi_az = {
    for i in local.self_managed_node_groups_multi_az_list: i.name => i
  }

  self_managed_node_groups = merge(local.self_managed_node_groups_multi_az, var.self_managed_node_groups)

  # place for defaults
  eks_managed_node_group_templates_for_multi_az = merge(
    {},
    var.eks_managed_node_group_templates_for_multi_az
  )

  eks_managed_node_groups_multi_az_list = flatten([
    for key, value in local.eks_managed_node_group_templates_for_multi_az: [
      for az in slice(local.subnets_by_az, 0, local.eks_managed_node_group_number_of_multi_az): merge(
        value,
        {
          key         = key
          name        = "${key}_${az.zone}"
          subnet_ids  = az.subnets
        }
      )
    ]
  ])

  eks_managed_node_groups_multi_az = {
    for i in local.eks_managed_node_groups_multi_az_list: i.name => i
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
# disable this as coredns and some other addons
# had untolerated taint {eks.amazonaws.com/compute-type: fargate}.
# and also EKS has quote for 10 fargate profiles by default.
# and also all fargate instances was started in one AZ instead of splitting by AZs
#     {
#       # default = {}
#       kube-system = {}
#       kube-node-lease = {}
#       kube-public = {}
#       cert-manager = {}
#       external-dns = {}
#       external-secrets = {}
#       vpa = {}
#       aws-node-termination-handler = {}
#     },
    {},
    var.fargate_profile_templates_for_multi_az
  )

  fargate_profiles_multi_az_list = flatten([
    for key, value in local.fargate_profile_templates_for_multi_az: [
      for az in slice(local.subnets_by_az, 0, local.fargate_profile_number_of_multi_az): merge(
        value,
        {
          key         = key
          name        = "${key}_${az.zone}"
          subnet_ids  = az.subnets
          selectors   = try(
            value.selectors,
            [{namespace = key}]
          )
          tags        = merge(try(value.tags, {}), var.tags)
        }
      )
    ]
  ])

  fargate_profiles_multi_az = {
    for i in local.fargate_profiles_multi_az_list: i.name => i
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
      kube-proxy = {
        most_recent = true
      }
      vpc-cni = {
        most_recent = true
        service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
      }
      aws-ebs-csi-driver = {
        most_recent = true
        service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
      }
      snapshot-controller = {
        most_recent = true
      }
    },
    var.cluster_addons
  )

  universal_addon_config = {
    values = [templatefile("${path.module}/universal_values.yaml", {})]
  }

  aws_efs_csi_driver_config = merge(local.universal_addon_config, var.aws_efs_csi_driver_config)

  # aws_node_termination_handler_config = merge(local.universal_addon_config, var.aws_node_termination_handler_config)

  cert_manager_config = merge(local.universal_addon_config, var.cert_manager_config)

  cluster_autoscaler_config = merge(local.universal_addon_config, var.cluster_autoscaler_config)

  metrics_server_config = merge(local.universal_addon_config, var.metrics_server_config)

  vpa_config = merge(local.universal_addon_config, var.vpa_config)

  # don't like using root password for monitoring agents but for speedup
  openobserve_authorization = try(base64encode("${var.admin_email}:${module.openobserve.zo_root_user_password}"), "")

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

module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.20"

  role_name_prefix = "${var.cluster_name}-ebs-csi-driver-"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = var.tags
}

module "vpc_cni_irsa" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.20"

  role_name_prefix = "${var.cluster_name}-vpc-cni-"

  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = var.tags
}

module "addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.1"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = local.cluster_addons

  # https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/0e9d6c9b7115ecf0404c377c9c2529bffa56d10d/docs/addons/aws-efs-csi-driver.md
  enable_aws_efs_csi_driver = var.enable_aws_efs_csi_driver
  aws_efs_csi_driver = local.aws_efs_csi_driver_config

  # https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/0e9d6c9b7115ecf0404c377c9c2529bffa56d10d/docs/addons/aws-node-termination-handler.md
  #enable_aws_node_termination_handler = var.enable_aws_node_termination_handler
  #aws_node_termination_handler = local.aws_node_termination_handler_config

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

# INGRESS APISIX

module "ingress_apisix" {
  source = "./modules/apisix"
  count = var.enable_ingress_apisix ? 1 : 0

  depends_on = [
    module.eks,
    module.addons
  ]

  create        = var.enable_ingress_apisix
  chart_version = can(var.ingress_apisix_chart_version) ? var.ingress_apisix_chart_version : null
  namespace     = var.ingress_apisix_namespace
  tags          = var.tags

  values = [
    templatefile("${path.module}/universal_values.yaml", {})
  ]
}

# OPERATOR

module "victoriametrics_operator" {
  source = "./modules/victoriametrics-operator"
  count = var.enable_victoriametrics_operator ? 1 : 0

  depends_on = [
    module.eks,
    module.addons
  ]

  create        = var.enable_victoriametrics_operator
  chart_version = var.victoriametrics_operator_chart_version
  namespace     = var.victoriametrics_operator_namespace
  set           = var.victoriametrics_operator_set
  tags          = var.tags

  values = concat(
    [templatefile("${path.module}/universal_values.yaml", {})],
    var.victoriametrics_operator_values
  )
}

module "opentelemetry_operator" {
  source = "./modules/opentelemetry-operator"
  count = var.enable_opentelemetry_operator ? 1 : 0

  depends_on = [
    module.eks,
    module.addons
  ]

  create        = var.enable_opentelemetry_operator
  chart_version = var.opentelemetry_operator_chart_version
  namespace     = var.opentelemetry_operator_namespace
  set           = var.opentelemetry_operator_set
  tags          = var.tags

  values = concat(
    [templatefile("${path.module}/universal_values.yaml", {})],
    var.opentelemetry_operator_values
  )
}

module "grafana_operator" {
  source = "./modules/grafana-operator"
  count = var.enable_grafana_operator ? 1 : 0

  depends_on = [
    module.eks,
    module.addons
  ]

  create        = var.enable_grafana_operator
  chart_version = var.grafana_operator_chart_version
  namespace     = var.grafana_operator_namespace
  set           = var.grafana_operator_set
  tags          = var.tags

  values = concat(
    [templatefile("${path.module}/universal_values.yaml", {})],
    var.grafana_operator_values
  )
}

module "clickhouse_operator" {
  source = "./modules/clickhouse-operator"
  count = var.enable_clickhouse_operator ? 1 : 0

  depends_on = [
    module.eks,
    module.addons
  ]

  create        = var.enable_clickhouse_operator
  chart_version = var.clickhouse_operator_chart_version
  namespace     = var.clickhouse_operator_namespace
  set           = var.clickhouse_operator_set
  tags          = var.tags

  values = concat(
    [templatefile("${path.module}/universal_values.yaml", {})],
    var.clickhouse_operator_values
  )
}

# MONITORING

# signoz.io vs openobserve.ai vs qryn.metrico.in vs uptrace.dev vs skywalking.apache.org
# https://uptrace.dev/get/open-source-apm.html#why-not

module "uptrace" {
  source = "./modules/uptrace"
  count = var.enable_uptrace ? 1 : 0

  depends_on = [
    module.eks,
    module.addons
  ]

  create        = var.enable_uptrace
  chart_version = var.uptrace_chart_version
  namespace     = var.uptrace_namespace
  set           = var.uptrace_set
  tags          = var.tags

  root_email    = var.admin_email
  oidc_provider_arn     = module.eks.oidc_provider_arn

  values = concat(
    [templatefile("${path.module}/universal_values.yaml", {})],
    var.uptrace_values
  )

  clickhouse_chart_version = var.uptrace_clickhouse_chart_version
  clickhouse_set           = var.uptrace_clickhouse_set

  clickhouse_values = concat(
    [templatefile("${path.module}/universal_values.yaml", {})],
    var.uptrace_clickhouse_values
  )

  postgresql_chart_version = var.uptrace_postgresql_chart_version
  postgresql_set           = var.uptrace_postgresql_set

  postgresql_values = concat(
    [templatefile("${path.module}/universal_values.yaml", {})],
    var.uptrace_postgresql_values
  )
}

module "qryn" {
  source = "./modules/qryn"
  count = var.enable_qryn ? 1 : 0

  depends_on = [
    module.eks,
    module.addons
  ]

  create        = var.enable_qryn
  chart_version = var.qryn_chart_version
  namespace     = var.qryn_namespace
  set           = var.qryn_set
  tags          = var.tags

  root_email    = var.admin_email
  oidc_provider_arn     = module.eks.oidc_provider_arn

  values = concat(
    [templatefile("${path.module}/universal_values.yaml", {})],
    var.qryn_values
  )

  clickhouse_chart_version = var.qryn_clickhouse_chart_version
  clickhouse_set           = var.qryn_clickhouse_set

  clickhouse_values = concat(
    [templatefile("${path.module}/universal_values.yaml", {})],
    var.qryn_clickhouse_values
  )
}

module "openobserve" {
  source = "./modules/openobserve"
  count = var.enable_openobserve ? 1 : 0

  depends_on = [
    module.eks,
    module.addons
  ]

  create        = var.enable_openobserve
  chart         = var.openobserve_chart_name
  chart_version = var.openobserve_chart_version
  namespace     = var.openobserve_namespace
  set           = var.openobserve_set
  tags          = var.tags

  zo_root_user_email    = var.admin_email
  oidc_provider_arn     = module.eks.oidc_provider_arn

  values = concat(
    [templatefile("${path.module}/universal_values.yaml", {})],
    var.openobserve_values
  )
}

module "openobserve_collector" {
  source = "./modules/openobserve-collector"
  count = var.enable_openobserve_collector ? 1 : 0

  depends_on = [
    module.eks,
    module.addons,
    module.opentelemetry_operator
  ]

  create        = var.enable_openobserve_collector
  chart_version = var.openobserve_collector_chart_version
  namespace     = var.openobserve_collector_namespace
  set           = var.openobserve_collector_set
  tags          = var.tags

  zo_endpoint      = "http://${var.openobserve_chart_name}.${var.openobserve_namespace}.svc.cluster.local:5080/api/default/"
  zo_authorization = "Basic ${local.openobserve_authorization}"

  values = concat(
    [templatefile("${path.module}/universal_values.yaml", {})],
    var.openobserve_collector_values
  )
}

# DASHBOARD

module "kubernetes_dashboard" {
  source = "./modules/kubernetes-dashboard"
  count = var.enable_kubernetes_dashboard ? 1 : 0

  depends_on = [
    module.eks,
    module.addons
  ]

  create        = var.enable_kubernetes_dashboard
  chart_version = var.kubernetes_dashboard_chart_version
  namespace     = var.kubernetes_dashboard_namespace
  set           = var.kubernetes_dashboard_set
  tags          = var.tags

  values = concat(
    [templatefile("${path.module}/universal_values.yaml", {})],
    var.kubernetes_dashboard_values
  )
}
