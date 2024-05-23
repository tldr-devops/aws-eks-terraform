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
    configuration_values = jsonencode(yamldecode(file("${path.module}/universal_values.yaml")))
  }

  eks_addons = merge(
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
    var.eks_addons
  )

  universal_values_string = templatefile("${path.module}/universal_values.yaml",  {})
  universal_addon_config = {
    values = [local.universal_values_string]
  }

  # https://github.com/kubernetes-sigs/aws-efs-csi-driver/blob/master/charts/aws-efs-csi-driver/values.yaml
  aws_efs_csi_driver_config = merge(
    local.universal_addon_config,
    {
      chart_version = null
      reset_values  = true
      values = [
        <<-EOT
          controller:
            ${replace(local.universal_values_string, "\n", "\n  ")}
        EOT
      ]
    },
    var.aws_efs_csi_driver_config
  )

  # https://github.com/aws/aws-node-termination-handler/blob/main/config/helm/aws-node-termination-handler/values.yaml
  aws_node_termination_handler_config = merge(
    local.universal_addon_config,
    {
      chart_version = null
      reset_values  = true
    },
    var.aws_node_termination_handler_config
  )
  aws_node_termination_handler_asg_arns = concat(
    [for asg in module.eks.self_managed_node_groups : asg.autoscaling_group_arn],
    var.aws_node_termination_handler_asg_arns
  )

  # https://github.com/cert-manager/cert-manager/blob/master/deploy/charts/cert-manager/values.yaml
  cert_manager_config = merge(
    local.universal_addon_config,
    {
      chart_version = null
      reset_values  = true
      values = [
        <<-EOT
          webhook:
            ${replace(local.universal_values_string, "\n", "\n  ")}
          cainjector:
            ${replace(local.universal_values_string, "\n", "\n  ")}
          startupapicheck:
            ${replace(local.universal_values_string, "\n", "\n  ")}
        EOT
      ]
    },
    var.cert_manager_config
  )

  # https://github.com/kubernetes/autoscaler/blob/master/charts/cluster-autoscaler/values.yaml
  cluster_autoscaler_config = merge(
    local.universal_addon_config,
    {
      chart_version = null
      reset_values  = true
    },
    var.cluster_autoscaler_config
  )

  # https://github.com/kubernetes-sigs/metrics-server/blob/master/charts/metrics-server/values.yaml
  metrics_server_config = merge(
    local.universal_addon_config,
    {
      chart_version = null
      reset_values  = true
    },
    var.metrics_server_config
  )

  # https://github.com/FairwindsOps/charts/blob/master/stable/vpa/values.yaml
  vpa_config = merge(
    local.universal_addon_config,
    {
      chart_version = null
      reset_values  = true
      values = [
        <<-EOT
          recommender:
            ${replace(local.universal_values_string, "\n", "\n  ")}
          updater:
            ${replace(local.universal_values_string, "\n", "\n  ")}
          admissionController:
            ${replace(local.universal_values_string, "\n", "\n  ")}
          mutatingWebhookConfiguration:
            ${replace(local.universal_values_string, "\n", "\n  ")}
        EOT
      ]
    },
    var.vpa_config
  )

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

# IRSA

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

  eks_addons          = local.eks_addons
  eks_addons_timeouts = var.eks_addons_timeouts

  # https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/0e9d6c9b7115ecf0404c377c9c2529bffa56d10d/docs/addons/aws-efs-csi-driver.md
  # https://github.com/kubernetes-sigs/aws-efs-csi-driver/blob/master/charts/aws-efs-csi-driver/values.yaml
  enable_aws_efs_csi_driver = var.enable_aws_efs_csi_driver
  aws_efs_csi_driver        = local.aws_efs_csi_driver_config

  # https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/0e9d6c9b7115ecf0404c377c9c2529bffa56d10d/docs/addons/aws-node-termination-handler.md
  # https://github.com/aws/aws-node-termination-handler/blob/main/config/helm/aws-node-termination-handler/values.yaml
  enable_aws_node_termination_handler   = var.enable_aws_node_termination_handler && length(local.aws_node_termination_handler_asg_arns) > 0
  aws_node_termination_handler          = local.aws_node_termination_handler_config
  aws_node_termination_handler_sqs      = var.aws_node_termination_handler_sqs
  aws_node_termination_handler_asg_arns = local.aws_node_termination_handler_asg_arns

  # https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/0e9d6c9b7115ecf0404c377c9c2529bffa56d10d/docs/addons/cert-manager.md
  # https://github.com/cert-manager/cert-manager/blob/master/deploy/charts/cert-manager/values.yaml
  enable_cert_manager                   = var.enable_cert_manager
  cert_manager                          = local.cert_manager_config
  cert_manager_route53_hosted_zone_arns = var.cert_manager_route53_hosted_zone_arns

  # https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/0e9d6c9b7115ecf0404c377c9c2529bffa56d10d/docs/addons/cluster-autoscaler.md
  # https://github.com/kubernetes/autoscaler/blob/master/charts/cluster-autoscaler/values.yaml
  enable_cluster_autoscaler = var.enable_cluster_autoscaler
  cluster_autoscaler        = local.cluster_autoscaler_config

  # https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/0e9d6c9b7115ecf0404c377c9c2529bffa56d10d/docs/addons/metrics-server.md
  # https://github.com/kubernetes-sigs/metrics-server/blob/master/charts/metrics-server/values.yaml
  enable_metrics_server = var.enable_metrics_server
  metrics_server        = local.metrics_server_config

  # https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/0e9d6c9b7115ecf0404c377c9c2529bffa56d10d/docs/addons/vertical-pod-autoscaler.md
  # https://github.com/FairwindsOps/charts/blob/master/stable/vpa/values.yaml
  enable_vpa = var.enable_vpa
  vpa        = local.vpa_config

  tags = var.tags
}

# patch addons and modules as some eks addons don't have tolerations
resource "null_resource" "apply_kubectl_patch" {

  count = var.apply_kubectl_patch? 1 : 0

  depends_on = [
    #module.eks,
    module.addons
  ]

  provisioner "local-exec" {
    command = <<-EOT
      export KUBECONFIG="${module.eks.kubeconfig}"
      kubectl get deployments -o name -n kube-system | xargs -I {} kubectl patch {} -n kube-system -p '{"spec": {"template":{"spec":${jsonencode(yamldecode(file("${path.module}/universal_values.yaml")))}}}}'
    EOT
  }
}

# https://cert-manager.io/docs/configuration/acme/
module "cert_manager_acme_manifests" {
  source = "./modules/kubernetes-manifests"
  count = var.enable_cert_manager ? 1 : 0

  depends_on = [
    #module.eks,
    module.addons
  ]

  create        = true
  name          = "cert-manager-acme-manifests"
  namespace     = try(var.cert_manager_config.namespace, "cert-manager")
  tags          = var.tags

  values = [
    <<-EOT
    resources:
      - apiVersion: cert-manager.io/v1
        kind: ClusterIssuer
        metadata:
          name: letsencrypt-staging
        spec:
          acme:
            email: "${var.admin_email}"
            server: "https://acme-staging-v02.api.letsencrypt.org/directory"
            privateKeySecretRef:
              name: cert-manager-issuer-letsencrypt-staging-account-key
            solvers:
              - http01:
                  ingress:
                    ingressClassName: "${var.ingress_class_name}"
      - apiVersion: cert-manager.io/v1
        kind: ClusterIssuer
        metadata:
          name: letsencrypt-prod
        spec:
          acme:
            email: "${var.admin_email}"
            server: "https://acme-v01.api.letsencrypt.org/directory"
            privateKeySecretRef:
              name: cert-manager-issuer-letsencrypt-prod-account-key
            solvers:
              - http01:
                  ingress:
                    ingressClassName: "${var.ingress_class_name}"
    EOT
  ]
}

# OPERATOR

module "victoriametrics_operator" {
  source = "./modules/victoriametrics-operator"
  count = var.enable_victoriametrics_operator ? 1 : 0

  depends_on = [
    #module.eks,
    #module.addons
  ]

  create        = var.enable_victoriametrics_operator
  chart_version = var.victoriametrics_operator_chart_version
  namespace     = var.victoriametrics_operator_namespace
  set           = var.victoriametrics_operator_set
  tags          = var.tags

  values = concat(
    [local.universal_values_string],
    var.victoriametrics_operator_values
  )
}

module "opentelemetry_operator" {
  source = "./modules/opentelemetry-operator"
  count = var.enable_opentelemetry_operator ? 1 : 0

  depends_on = [
    #module.eks,
    #module.addons
    module.victoriametrics_operator
  ]

  create        = var.enable_opentelemetry_operator
  chart_version = var.opentelemetry_operator_chart_version
  namespace     = var.opentelemetry_operator_namespace
  set           = var.opentelemetry_operator_set
  tags          = var.tags

  values = concat(
    [local.universal_values_string],
    [
    <<-EOT
      %{ if var.enable_victoriametrics_operator == true }
      manager:
        serviceMonitor:
          enabled: true
      %{ endif }
    EOT
    ],
    var.opentelemetry_operator_values
  )
}

module "grafana_operator" {
  source = "./modules/grafana-operator"
  count = var.enable_grafana_operator ? 1 : 0

  depends_on = [
    #module.eks,
    #module.addons
  ]

  create        = var.enable_grafana_operator
  chart_version = var.grafana_operator_chart_version
  namespace     = var.grafana_operator_namespace
  set           = var.grafana_operator_set
  tags          = var.tags

  values = concat(
    [local.universal_values_string],
    var.grafana_operator_values
  )
}

module "clickhouse_operator" {
  source = "./modules/clickhouse-operator"
  count = var.enable_clickhouse_operator ? 1 : 0

  depends_on = [
    #module.eks,
    #module.addons
  ]

  create        = var.enable_clickhouse_operator
  chart_version = var.clickhouse_operator_chart_version
  namespace     = var.clickhouse_operator_namespace
  set           = var.clickhouse_operator_set
  tags          = var.tags

  values = concat(
    [local.universal_values_string],
    var.clickhouse_operator_values
  )
}

# INGRESS

module "ingress_apisix" {
  source = "./modules/apisix"
  count = var.enable_ingress_apisix ? 1 : 0

  depends_on = [
    #module.eks,
    #module.addons
    module.victoriametrics_operator
  ]

  create        = var.enable_ingress_apisix
  chart_version = var.ingress_apisix_chart_version
  namespace     = var.ingress_apisix_namespace
  set           = var.ingress_apisix_set
  tags          = var.tags

  values = concat(
    [local.universal_values_string],
    [
    <<-EOT
      %{ if var.enable_victoriametrics_operator == true }
      serviceMonitor:
        enabled: true
        namespace: "${var.ingress_apisix_namespace}"
      %{ endif }
    EOT
    ],
    var.ingress_apisix_values
  )
}

module "ingress_nginx" {
  source = "./modules/nginx"
  count = var.enable_ingress_nginx ? 1 : 0

  depends_on = [
    #module.eks,
    #module.addons
    module.victoriametrics_operator
  ]

  create        = var.enable_ingress_nginx
  chart_version = var.ingress_nginx_chart_version
  namespace     = var.ingress_nginx_namespace
  set           = var.ingress_nginx_set
  tags          = var.tags

  values = concat(
    [
    <<-EOT
      controller:
        ${replace(local.universal_values_string, "\n", "\n  ")}
      defaultBackend:
        ${replace(local.universal_values_string, "\n", "\n  ")}
    EOT
    ],
    [
    <<-EOT
      %{ if var.enable_victoriametrics_operator == true }
      controller:
        metrics:
          serviceMonitor:
            enabled: true
            namespace: "${var.ingress_nginx_namespace}"
            scrapeInterval: 30s # default
      %{ endif }
    EOT
    ],
    var.ingress_nginx_values
  )
}

# MONITORING

module "victoriametrics" {
  source = "./modules/victoriametrics"
  count = var.enable_victoriametrics ? 1 : 0

  depends_on = [
    #module.eks,
    #module.addons,
    module.victoriametrics_operator,
    module.grafana_operator,
#     module.uptrace,
#     module.qryn
  ]

  create        = var.enable_victoriametrics
  chart_version = var.victoriametrics_chart_version
  namespace     = var.victoriametrics_namespace
  set           = var.victoriametrics_set
  tags          = var.tags

  grafana_admin_user = var.admin_email
  grafana_operator_integration  = var.enable_grafana_operator
  grafana_operator_namespace    = var.grafana_operator_namespace

  values = concat(
    [local.universal_values_string],
    [
    <<-EOT
      %{ if var.enable_victoriametrics_operator == true }
      victoria-metrics-operator:
        enabled: false
      crds:
        enabled: false
      %{ endif }
    EOT
    ,
    <<-EOT
      %{ if var.enable_grafana_operator == true || var.enable_grafana == true }
      grafanaOperatorDashboardsFormat:
        enabled: true
        instanceSelector:
          matchLabels:
            dashboards: "grafana"
        allowCrossNamespaceImport: true
      grafana:
        enabled: false
      %{ else }
      %{ if var.victoriametrics_grafana_ingress_enabled == true }
      grafana:
        enabled: true
        ingress:
          enabled: true
          ingressClassName: ${var.ingress_class_name}
          # https://apisix.apache.org/docs/ingress-controller/concepts/annotations/
          # https://cert-manager.io/docs/usage/ingress/
          annotations:
          kubernetes.io/ingress.class: ${var.ingress_class_name}
          k8s.apisix.apache.org/enable-cors: "true"
          %{~ if coalesce(var.victoriametrics_cert_manager_issuer, var.cert_manager_issuer, false) ~}
          k8s.apisix.apache.org/http-to-https: "true"
          cert-manager.io/cluster-issuer: ${coalesce(var.victoriametrics_cert_manager_issuer, var.cert_manager_issuer)}
          %{ endif }
          hosts:
            - grafana.${var.ingress_domain}
          %{~ if coalesce(var.victoriametrics_cert_manager_issuer, var.cert_manager_issuer, false) ~}
          tls:
            - secretName: grafana-${var.victoriametrics_namespace}-tls
              hosts:
              - grafana.${var.ingress_domain}
          %{ else }
          tls: []
          %{ endif }
      %{ endif }
      %{ endif }
    EOT
    ,
    <<-EOT
      %{ if var.enable_uptrace == true || var.enable_qryn == true }
      vmagent:
        # https://docs.victoriametrics.com/operator/api/#vmagentremotewritespec
        # https://uptrace.dev/get/ingest/prometheus.html#prometheus-remote-write
        additionalRemoteWrites:
          %{ if var.enable_uptrace == true }
          - url: "http://${module.uptrace[0].chart.uptrace}.${module.uptrace[0].namespace.uptrace}.svc:14318/api/v1/prometheus/write"
            headers:
              - "uptrace-dsn: http://${module.uptrace[0].project_tokens[1]}@${module.uptrace[0].chart.uptrace}.${module.uptrace[0].namespace.uptrace}.svc:14318/2?grpc=14317"
          %{ endif }
          %{ if var.enable_qryn == true }
          - url: "http://${var.admin_email}:${module.qryn[0].root_password}@${module.qryn[0].chart.qryn}.${module.qryn[0].namespace.qryn}.svc:3100/api/v1/write"
          %{ endif }
      %{ endif }
    EOT
    ],
    var.victoriametrics_values
  )

  auth_chart_version = var.victoriametrics_auth_chart_version
  auth_set           = var.victoriametrics_auth_set
  auth_values        = concat(
    [local.universal_values_string],
    [
    <<-EOT
      %{ if var.victoriametrics_auth_ingress_enabled == true }
      ingress:
        enabled: true
        ingressClassName: ${var.ingress_class_name}
        # https://apisix.apache.org/docs/ingress-controller/concepts/annotations/
        # https://cert-manager.io/docs/usage/ingress/
        annotations:
          kubernetes.io/ingress.class: ${var.ingress_class_name}
          k8s.apisix.apache.org/enable-cors: "true"
          %{~ if coalesce(var.victoriametrics_cert_manager_issuer, var.cert_manager_issuer, false) ~}
          k8s.apisix.apache.org/http-to-https: "true"
          cert-manager.io/cluster-issuer: ${coalesce(var.victoriametrics_cert_manager_issuer, var.cert_manager_issuer)}
          %{ endif }
        hosts:
          - name: vmauth.${var.ingress_domain}
            path: /
            port: http
          - name: victoriametrics.${var.ingress_domain}
            path: /
            port: http
          - name: vmalertmanager.${var.ingress_domain}
            path: /
            port: http
          - name: vmagent.${var.ingress_domain}
            path: /
            port: http
          - name: vmalert.${var.ingress_domain}
            path: /
            port: http
        %{~ if coalesce(var.victoriametrics_cert_manager_issuer, var.cert_manager_issuer, false) ~}
        tls:
          - secretName: vmauth-${var.victoriametrics_namespace}-tls
            hosts:
              - vmauth.${var.ingress_domain}
              - victoriametrics.${var.ingress_domain}
              - vmalertmanager.${var.ingress_domain}
              - vmagent.${var.ingress_domain}
              - vmalert.${var.ingress_domain}
        %{ else }
        tls: []
        %{ endif }
      %{ endif }
    EOT
    ],
    var.victoriametrics_auth_values
  )

}

module "grafana" {
  source = "./modules/grafana"
  count = var.enable_grafana ? 1 : 0

  depends_on = [
    #module.eks,
    #module.addons,
    module.grafana_operator,
    module.victoriametrics_operator
  ]

  create        = var.enable_grafana
  chart_version = var.grafana_chart_version
  namespace     = var.grafana_namespace
  set           = var.grafana_set
  tags          = var.tags

  admin_user                    = var.admin_email
  grafana_operator_integration  = var.enable_grafana_operator
  grafana_operator_namespace    = var.grafana_operator_namespace

  values = concat(
    [local.universal_values_string],
    [
    <<-EOT
      %{ if var.enable_victoriametrics_operator == true }
      serviceMonitor:
        enabled: true
      %{ endif }
      %{ if var.grafana_ingress_enabled == true }
      ingress:
        enabled: true
        ingressClassName: ${var.ingress_class_name}
        # https://apisix.apache.org/docs/ingress-controller/concepts/annotations/
        # https://cert-manager.io/docs/usage/ingress/
        annotations:
          kubernetes.io/ingress.class: ${var.ingress_class_name}
          k8s.apisix.apache.org/enable-cors: "true"
          %{~ if coalesce(var.grafana_cert_manager_issuer, var.cert_manager_issuer, false) ~}
          k8s.apisix.apache.org/http-to-https: "true"
          cert-manager.io/cluster-issuer: ${coalesce(var.grafana_cert_manager_issuer, var.cert_manager_issuer)}
          %{ endif }
        hosts:
          - grafana.${var.ingress_domain}
        %{~ if coalesce(var.grafana_cert_manager_issuer, var.cert_manager_issuer, false) ~}
        tls:
          - secretName: grafana-${var.grafana_namespace}-tls
            hosts:
              - grafana.${var.ingress_domain}
        %{ else }
        tls: []
        %{ endif }
      %{ endif }
    EOT
    ],
    var.grafana_values
  )
}

# signoz.io vs openobserve.ai vs qryn.metrico.in vs uptrace.dev vs skywalking.apache.org vs siglens.com
# https://uptrace.dev/get/open-source-apm.html#why-not

module "uptrace" {
  source = "./modules/uptrace"
  count = var.enable_uptrace ? 1 : 0

  depends_on = [
    #module.eks,
    #module.addons
  ]

  create        = var.enable_uptrace
  chart_version = var.uptrace_chart_version
  namespace     = var.uptrace_namespace
  set           = var.uptrace_set
  tags          = var.tags

  root_email    = var.admin_email
  oidc_provider_arn     = module.eks.oidc_provider_arn
  grafana_operator_integration  = var.enable_grafana_operator
  grafana_operator_namespace    = var.grafana_operator_namespace

  values = concat(
    [local.universal_values_string],
    [
    <<-EOT
      %{ if var.uptrace_ingress_enabled == true }
      uptrace:
        config:
          site:
            addr: 'https://uptrace.${var.ingress_domain}/'
      ingress:
        enabled: true
        className: ${var.ingress_class_name}
        # https://apisix.apache.org/docs/ingress-controller/concepts/annotations/
        # https://cert-manager.io/docs/usage/ingress/
        annotations:
          kubernetes.io/ingress.class: ${var.ingress_class_name}
          k8s.apisix.apache.org/enable-cors: "true"
          %{~ if coalesce(var.uptrace_cert_manager_issuer, var.cert_manager_issuer, false) ~}
          k8s.apisix.apache.org/http-to-https: "true"
          cert-manager.io/cluster-issuer: ${coalesce(var.uptrace_cert_manager_issuer, var.cert_manager_issuer)}
          %{ endif }
        hosts:
          - host: uptrace.${var.ingress_domain}
            paths:
              - path: /
                pathType: Prefix
        %{~ if coalesce(var.uptrace_cert_manager_issuer, var.cert_manager_issuer, false) ~}
        tls:
          - secretName: uptrace-${var.uptrace_namespace}-tls
            hosts:
              - uptrace.${var.ingress_domain}
        %{ else }
        tls: []
        %{ endif }
      %{ endif }
    EOT
    ],
    var.uptrace_values
  )

  clickhouse_chart_version = var.uptrace_clickhouse_chart_version
  clickhouse_set           = var.uptrace_clickhouse_set

  clickhouse_values = concat(
    [local.universal_values_string],
    var.uptrace_clickhouse_values
  )

  postgresql_chart_version = var.uptrace_postgresql_chart_version
  postgresql_set           = var.uptrace_postgresql_set

  postgresql_values = concat(
    [local.universal_values_string],
    var.uptrace_postgresql_values
  )
}

module "qryn" {
  source = "./modules/qryn"
  count = var.enable_qryn ? 1 : 0

  depends_on = [
    #module.eks,
    #module.addons
    module.victoriametrics_operator
  ]

  create        = var.enable_qryn
  chart_version = var.qryn_chart_version
  namespace     = var.qryn_namespace
  set           = var.qryn_set
  tags          = var.tags

  root_email    = var.admin_email
  oidc_provider_arn     = module.eks.oidc_provider_arn
  grafana_operator_integration  = var.enable_grafana_operator
  grafana_operator_namespace    = var.grafana_operator_namespace

  values = concat(
    [local.universal_values_string],
    [
    <<-EOT
      %{ if var.enable_victoriametrics_operator == true }
      serviceMonitor:
        enabled: true
      %{ endif }
      %{ if var.qryn_ingress_enabled == true }
      ingress:
        enabled: true
        className: ${var.ingress_class_name}
        # https://apisix.apache.org/docs/ingress-controller/concepts/annotations/
        # https://cert-manager.io/docs/usage/ingress/
        annotations:
          kubernetes.io/ingress.class: ${var.ingress_class_name}
          k8s.apisix.apache.org/enable-cors: "true"
          %{~ if coalesce(var.qryn_cert_manager_issuer, var.cert_manager_issuer, false) ~}
          k8s.apisix.apache.org/http-to-https: "true"
          cert-manager.io/cluster-issuer: ${coalesce(var.qryn_cert_manager_issuer, var.cert_manager_issuer)}
          %{ endif }
        hosts:
          - host: qryn.${var.ingress_domain}
            paths:
              - path: /
                pathType: ImplementationSpecific
        %{~ if coalesce(var.qryn_cert_manager_issuer, var.cert_manager_issuer, false) ~}
        tls:
          - secretName: qryn-${var.qryn_namespace}-tls
            hosts:
              - qryn.${var.ingress_domain}
        %{ else }
        tls: []
        %{ endif }
      %{ endif }
    EOT
    ],
    var.qryn_values
  )

  clickhouse_chart_version = var.qryn_clickhouse_chart_version
  clickhouse_set           = var.qryn_clickhouse_set

  clickhouse_values = concat(
    [local.universal_values_string],
    var.qryn_clickhouse_values
  )
}

module "openobserve" {
  source = "./modules/openobserve"
  count = var.enable_openobserve ? 1 : 0

  depends_on = [
    #module.eks,
    #module.addons
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
    [local.universal_values_string],
    [
    <<-EOT
      %{ if var.openobserve_ingress_enabled == true }
      ingress:
        enabled: true
        className: ${var.ingress_class_name}
        # https://apisix.apache.org/docs/ingress-controller/concepts/annotations/
        # https://cert-manager.io/docs/usage/ingress/
        annotations:
          kubernetes.io/ingress.class: ${var.ingress_class_name}
          k8s.apisix.apache.org/enable-cors: "true"
          %{~ if coalesce(var.openobserve_cert_manager_issuer, var.cert_manager_issuer, false) ~}
          k8s.apisix.apache.org/http-to-https: "true"
          cert-manager.io/cluster-issuer: ${coalesce(var.openobserve_cert_manager_issuer, var.cert_manager_issuer)}
          %{ endif }
        hosts:
          - host: openobserve.${var.ingress_domain}
            paths:
              - path: /
                pathType: ImplementationSpecific
        %{~ if coalesce(var.openobserve_cert_manager_issuer, var.cert_manager_issuer, false) ~}
        tls:
          - secretName: openobserve-${var.openobserve_namespace}-tls
            hosts:
              - openobserve.${var.ingress_domain}
        %{ else }
        tls: []
        %{ endif }
      %{ endif }
    EOT
    ],
    var.openobserve_values
  )
}

module "openobserve_collector" {
  source = "./modules/openobserve-collector"
  count = var.enable_openobserve_collector ? 1 : 0

  depends_on = [
    #module.eks,
    #module.addons,
    module.opentelemetry_operator
  ]

  create        = var.enable_openobserve_collector
  chart_version = var.openobserve_collector_chart_version
  namespace     = var.openobserve_collector_namespace
  set           = var.openobserve_collector_set
  tags          = var.tags

  zo_endpoint      = "http://${var.openobserve_chart_name}.${var.openobserve_namespace}.svc:5080/api/default/"
  zo_authorization = "Basic ${local.openobserve_authorization}"

  values = concat(
    [local.universal_values_string],
    var.openobserve_collector_values
  )
}

# https://medium.com/ibm-cloud/log-collectors-performance-benchmarking-8c5218a08fea
# vector is still buggy =\ https://github.com/vectordotdev/vector/issues/12014
module "vector_agent" {
  source = "./modules/vector"
  count = var.enable_vector_agent ? 1 : 0

  create        = var.enable_vector_agent
  chart_version = var.vector_agent_chart_version
  namespace     = var.vector_agent_namespace
  set           = var.vector_agent_set
  tags          = var.tags

  values = concat(
    [local.universal_values_string],
    [
    <<-EOT
      role: "Agent"

      # customConfig -- Override Vector's default configs, if used **all** options need to be specified. This section supports
      # using helm templates to populate dynamic values. See Vector's [configuration documentation](https://vector.dev/docs/reference/configuration/)
      # for all options.
      customConfig:
        data_dir: /vector-data-dir
        api:
          enabled: true
          address: 127.0.0.1:8686
          playground: false

        # https://vector.dev/docs/reference/configuration/sources/
        sources:
          kubernetes_logs:
            type: kubernetes_logs
          internal_metrics:
            type: internal_metrics

        # https://vector.dev/docs/reference/configuration/transforms/
        transforms: {}

        # https://vector.dev/docs/reference/configuration/sinks/
        sinks:
          prom_exporter:
            type: prometheus_exporter
            inputs: [internal_metrics]
            address: 0.0.0.0:9090
          %{ if var.enable_uptrace == true }
          uptrace:
            type: "http"
            method: "post"
            inputs:
              - kubernetes_logs
            encoding:
              codec: "json"
            framing:
              method: "newline_delimited"
            compression: "gzip"
            request:
              headers:
                uptrace-dsn: "http://${module.uptrace[0].project_tokens[1]}@${module.uptrace[0].chart.uptrace}.${module.uptrace[0].namespace.uptrace}.svc:14318/2?grpc=14317"
            uri: "http://${module.uptrace[0].chart.uptrace}.${module.uptrace[0].namespace.uptrace}.svc:14318/api/v1/vector/logs"
          %{ endif }
          %{ if var.enable_qryn == true }
          qryn:
            type: "loki"
            inputs:
              - kubernetes_logs
            encoding:
              codec: "json"
            endpoint: "http://${module.qryn[0].chart.qryn}.${module.qryn[0].namespace.qryn}.svc:3100"
            auth:
              strategy: "basic"
              password: "${module.qryn[0].root_password}"
              user: "${var.admin_email}"
          %{ endif }
    EOT
    ],
    var.vector_agent_values
  )
}

# DASHBOARD

module "kubernetes_dashboard" {
  source = "./modules/kubernetes-dashboard"
  count = var.enable_kubernetes_dashboard ? 1 : 0

  depends_on = [
    #module.eks,
    #module.addons
  ]

  create        = var.enable_kubernetes_dashboard
  chart_version = var.kubernetes_dashboard_chart_version
  namespace     = var.kubernetes_dashboard_namespace
  set           = var.kubernetes_dashboard_set
  tags          = var.tags

  values = concat(
    [local.universal_values_string],
    [
    <<-EOT
    %{ if var.kubernetes_dashboard_ingress_enabled == true }
    app:
      ingress:
        enabled: true
        ingressClassName: ${var.ingress_class_name}
        # https://apisix.apache.org/docs/ingress-controller/concepts/annotations/
        # https://cert-manager.io/docs/usage/ingress/
        annotations:
          kubernetes.io/ingress.class: ${var.ingress_class_name}
          k8s.apisix.apache.org/enable-cors: "true"
          %{~ if coalesce(var.kubernetes_dashboard_cert_manager_issuer, var.cert_manager_issuer, false) ~}
          k8s.apisix.apache.org/http-to-https: "true"
          cert-manager.io/cluster-issuer: ${coalesce(var.kubernetes_dashboard_cert_manager_issuer, var.cert_manager_issuer)}
          %{ endif }
        hosts:
          - k8s-dashboard.${var.ingress_domain}
        %{~ if coalesce(var.kubernetes_dashboard_cert_manager_issuer, var.cert_manager_issuer, false) ~}
        tls:
          - secretName: kubernetes-dashboard-${var.kubernetes_dashboard_namespace}-tls
            hosts:
              - k8s-dashboard.${var.ingress_domain}
        %{ else }
        tls: []
        %{ endif }
    %{ endif }
    EOT
    ],
    var.kubernetes_dashboard_values
  )
}
