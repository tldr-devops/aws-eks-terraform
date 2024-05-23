provider "aws" {
  region = "us-east-2"
}

locals {
  cluster_name        = "test"
  admin_email         = "test@test.com"
  ingress_domain      = "cluster.local"
  ingress_class_name  = "apisix" # or "nginx"
  cert_manager_issuer = "" # you can set to "letsencrypt-staging" or "letsencrypt-prod" after configuring dns records

  cluster_version     = "1.29"

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

  # you can use templates for generating node groups and fargate profiles
  # one per each availability zone, limited by *number_of_multi_az variables
  self_managed_node_group_templates_for_multi_az = {}

  eks_managed_node_group_templates_for_multi_az = {
    management = {
      min_size     = 1
      desired_size = 1
      max_size     = 3

      instance_types = ["m6a.large"] # 2cpu 8gb ram 62$\mo https://instances.vantage.sh/aws/ec2/m6a.large

      labels = {
        "node.kubernetes.io/purpose" = "management"
      }

    # multiple pods don't have tolerations yet
    # including snapshot-controller plugin that can't be changed at all
    #   taints = {
    #     purpose = {
    #       key    = "node.kubernetes.io/purpose"
    #       value  = "management"
    #       effect = "NO_SCHEDULE"
    #     }
    #   }

    }
  }

  # Disable this as coredns and some other addons
  # had untolerated taint {eks.amazonaws.com/compute-type: fargate}.
  # Also EKS has quote for 10 fargate profiles by default.
  # And also all fargate instances was started in one AZ instead of splitting by AZs
  fargate_profile_templates_for_multi_az = {
#       default = {}
#       kube-system = {}
#       kube-node-lease = {}
#       kube-public = {}
#       cert-manager = {}
#       external-dns = {}
#       external-secrets = {}
#       vpa = {}
#       aws-node-termination-handler = {}
  }

  # Groups in all cluster networks and availability zones
  self_managed_node_groups = {
#     nth_test = {
#       min_size       = 0
#       desired_size   = 0
#       max_size       = 1
#       instance_types = ["t3.nano"]
#     }
  }
  eks_managed_node_groups = {}
  fargate_profiles = {}

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

  # using for filter private subnets
  map_public_ip_on_launch = true

  enable_nat_gateway = true
  single_nat_gateway = false
  one_nat_gateway_per_az = true

  enable_vpn_gateway = false

  tags = local.tags
}

module "eks" {
  source = "../"

  cluster_name                                    = local.cluster_name
  cluster_version                                 = local.cluster_version
  admin_email                                     = local.admin_email
  ingress_domain                                  = local.ingress_domain
  ingress_class_name                              = local.ingress_class_name
  cert_manager_issuer                             = local.cert_manager_issuer
  vpc_id                                          = module.vpc.vpc_id
  number_of_multi_az                              = local.number_of_multi_az
  self_managed_node_group_number_of_multi_az      = local.self_managed_node_group_number_of_multi_az
  eks_managed_node_group_number_of_multi_az       = local.eks_managed_node_group_number_of_multi_az
  fargate_profile_number_of_multi_az              = local.fargate_profile_number_of_multi_az
  self_managed_node_group_templates_for_multi_az  = local.self_managed_node_group_templates_for_multi_az
  eks_managed_node_group_templates_for_multi_az   = local.eks_managed_node_group_templates_for_multi_az
  fargate_profile_templates_for_multi_az          = local.fargate_profile_templates_for_multi_az
  self_managed_node_groups                        = local.self_managed_node_groups
  eks_managed_node_groups                         = local.eks_managed_node_groups
  fargate_profiles                                = local.fargate_profiles
  tags                                            = local.tags

  enable_aws_efs_csi_driver           = true
  enable_aws_node_termination_handler = true
  enable_cert_manager                 = true
  enable_cluster_autoscaler           = true
  enable_metrics_server               = true
  enable_vpa                          = true
  enable_ingress_apisix               = true
  enable_ingress_nginx                = false
  enable_victoriametrics_operator     = true
  enable_opentelemetry_operator       = true
  enable_clickhouse_operator          = true
  enable_grafana_operator             = true
  enable_victoriametrics              = true
  enable_grafana                      = true
  enable_uptrace                      = true
  enable_vector_agent                 = true
  enable_qryn                         = false
  enable_openobserve                  = false
  enable_openobserve_collector        = false
  enable_kubernetes_dashboard         = false


  # disable versions for install latest one
  # and then set it from the terraform output
  # to prevent unplanned upgrades

  eks_addons = {
    coredns             = {addon_version = "v1.11.1-eksbuild.9"}
    kube-proxy          = {addon_version = "v1.29.3-eksbuild.2"}
    vpc-cni             = {addon_version = "v1.18.1-eksbuild.3"}
    aws-ebs-csi-driver  = {addon_version = "v1.30.0-eksbuild.1"}
    snapshot-controller = {addon_version = "v7.0.1-eksbuild.1"}
  }

  aws_efs_csi_driver_config              = {chart_version = "3.0.3"}
  aws_node_termination_handler_config    = {chart_version = "0.21.0"}
  cert_manager_config                    = {chart_version = "v1.14.5"}
  cluster_autoscaler_config              = {chart_version = "9.37.0"}
  metrics_server_config                  = {chart_version = "3.12.1"}
  vpa_config                             = {chart_version = "4.4.6"}

  ingress_apisix_chart_version           = "0.14.0"
  ingress_nginx_chart_version            = "4.10.1"
  victoriametrics_operator_chart_version = "0.31.2"
  opentelemetry_operator_chart_version   = "0.58.2"
  clickhouse_operator_chart_version      = "0.23.5"
  grafana_operator_chart_version         = "4.2.4"
  victoriametrics_chart_version          = "0.22.1"
  victoriametrics_auth_chart_version     = "0.4.12"
  grafana_chart_version                  = "7.3.11"
  uptrace_chart_version                  = "1.7.4"
  uptrace_clickhouse_chart_version       = "6.0.7"
  uptrace_postgresql_chart_version       = "15.3.3"
  qryn_chart_version                     = "0.1.1"
  qryn_clickhouse_chart_version          = "6.0.7"
  openobserve_chart_name                 = "0.10.5"
  openobserve_collector_chart_version    = "0.3.6"
  kubernetes_dashboard_chart_version     = "7.4.0"
}
