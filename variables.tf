variable "admin_email" {
  description = "Email of cluster administrator"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "ID of target VPC, 'default' will be used by default"
  type        = string
  default     = ""
}

variable "subnets_by_az" {
  description = "List of objects that contain subnets ids sorted by availability zones"
  type        = list(object({
    subnets = list(string)
    zone    = string
  }))
  default     = null
}

variable "private_subnets_filters" {
  description = "List of filters for private subnets data source"
  type        = list(object({
    name   = string
    values = list(string)
  }))
  default     = [
    {
      name   = "map-public-ip-on-launch"
      values = ["false"]
    }
  ]
}

variable "number_of_multi_az" {
  description = "How many availability zones should be used for running control plane and nodes"
  type        = number
  default     = 3
}

variable "cluster_name" {
  description = "AWS EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "AWS EKS cluster version"
  type        = string
  default     = "1.28"
}

# https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/0e9d6c9b7115ecf0404c377c9c2529bffa56d10d/docs/amazon-eks-addons.md
variable "cluster_addons" {
  description = "AWS EKS cluster addons map, default is latest coredns, kube-proxy, vpc-cni, aws-ebs-csi-driver, snapshot-controller"
  type        = any
  default     = {}
}

variable "self_managed_node_group_defaults" {
  description = "Defaults configs for self_managed_node_groups"
  type        = any
  default     = {}
}

variable "eks_managed_node_group_defaults" {
  description = "Defaults configs for eks_managed_node_groups"
  type        = any
  default     = {}
}

variable "fargate_profile_defaults" {
  description = "Defaults configs for fargate_profiles"
  type        = any
  default     = {}
}

# https://docs.aws.amazon.com/eks/latest/APIReference/API_Nodegroup.html
# https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/submodules/eks-managed-node-group
variable "group_defaults" {
  description = "Defaults configs for self_managed_node_groups, eks_managed_node_groups and fargate_profiles"
  type        = any
  default     = {
    min_size     = 0
    max_size     = 5
    desired_size = 0

    instance_types = ["m6a.large"] #, "m5a.large", "m7i-flex.large", "m6i.large", "m5.large", "m4.large", "m7i.large"] # 2cpu 8gb
    # instance_types = ["c6a.large", "c5a.large", "c6i.large", "c5.large", "c5ad.large", "c5ad.large"] # 2cpu 4gb

    capacity_type = "ON_DEMAND" # "SPOT"
    platform      = "linux" # "bottlerocket"
    ami_type      = "AL2_x86_64" # "BOTTLEROCKET_x86_64"
    disk_size     = 20
    # ebs_optimized = true # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-optimized.html
    enclave_options = {}

    update_config = {
      max_unavailable_percentage = 33 # or set `max_unavailable`
    }

    # Needed by the aws-ebs-csi-driver
    iam_role_additional_policies = {
      # AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }

    tags = {
      Terraform = "true"
      Managed = "eks"
    }
  }
}

variable "self_managed_node_groups" {
  description = "Configs for self_managed_node_groups"
  type        = any
  default     = {}
}

variable "self_managed_node_group_templates_for_multi_az" {
  description = "Templates for generating similar self managed node group in each availability zone"
  type        = any
  default     = {}
}

variable "self_managed_node_group_number_of_multi_az" {
  description = "How many availability zones should be used for generating self managed node groups from template"
  type        = number
  default     = 3
}

variable "eks_managed_node_groups" {
  description = "Configs for eks_managed_node_groups"
  type        = any
  default     = {}
}

variable "eks_managed_node_group_templates_for_multi_az" {
  description = "Templates for generating similar eks managed node group in each availability zone"
  type        = any
  default     = {}
}

variable "eks_managed_node_group_number_of_multi_az" {
  description = "How many availability zones should be used for generating eks managed node groups from template"
  type        = number
  default     = 3
}

variable "fargate_profiles" {
  description = "Configs for fargate_profiles"
  type        = any
  default     = {}
}

variable "fargate_profile_templates_for_multi_az" {
  description = "Templates for generating similar fargate profiles in each availability zone"
  type        = any
  default     = {}
}

variable "fargate_profile_number_of_multi_az" {
  description = "How many availability zones should be used for generating fargate profiles from template"
  type        = number
  default     = 3
}

variable "admin_iam_roles" {
  description = "List of account roles that should have EKS amdin permissions"
  type    = list(string)
  default = []
}

variable "admin_iam_users" {
  description = "List of account users that should have EKS amdin permissions"
  type    = list(string)
  default = []
}

variable "eks_iam_roles" {
  description = "List of maps with iam roles that should map eks service accounts"
  type = list(object({
    role_name = string
    role_arn = string
    role_namespace = string
    role_policy_arns = any
  }))
  default = []
}

variable "tags" {
  description = "Tags for EKS"
  type        = map(any)
  default     = { Terraform = "true" }
}

variable "enable_aws_efs_csi_driver" {
  description = "Install latest AWS EFS CSI driver"
  type        = bool
  default     = true
}

variable "aws_efs_csi_driver_config" {
  description = "AWS EFS CSI driver configuration"
  type        = any
  default     = {}
}

# variable "enable_aws_node_termination_handler" {
#   description = "Install latest AWS node termination handler"
#   type        = bool
#   default     = true
# }
# 
# variable "aws_node_termination_handler_config" {
#   description = "AWS node termination handler configuration"
#   type        = any
#   default     = {}
# }

variable "enable_cert_manager" {
  description = "Install latest cert-manager"
  type        = bool
  default     = true
}

variable "cert_manager_config" {
  description = "Cert manager configuration"
  type        = any
  default     = {}
}

variable "enable_cluster_autoscaler" {
  description = "Install latest cluster autoscaler"
  type        = bool
  default     = true
}

variable "cluster_autoscaler_config" {
  description = "Cluster autoscaler configuration"
  type        = any
  default     = {}
}

variable "enable_metrics_server" {
  description = "Install latest metrics server"
  type        = bool
  default     = true
}

variable "metrics_server_config" {
  description = "Metrics server configuration"
  type        = any
  default     = {}
}

variable "enable_vpa" {
  description = "Install latest Vertical Pod Autoscaler"
  type        = bool
  default     = true
}

variable "vpa_config" {
  description = "Vertical Pod Autoscaler configuration"
  type        = any
  default     = {}
}

# INGRESS

variable "enable_ingress_apisix" {
  description = "Install ingress Apisix"
  type        = bool
  default     = true
}

variable "ingress_apisix_chart_version" {
  description = "Ingress Apisix chart version"
  type        = string
  default     = null
}

variable "ingress_apisix_namespace" {
  description = "Ingress Apisix namespace"
  type        = string
  default     = "ingress-apisix"
}

# OPERATORS

variable "enable_opentelemetry_operator" {
  description = "Install Opentelemetry Operator"
  type        = bool
  default     = true
}

variable "opentelemetry_operator_chart_version" {
  description = "Opentelemetry Operator chart version"
  type        = string
  default     = null
}

variable "opentelemetry_operator_namespace" {
  description = "Opentelemetry Operator namespace"
  type        = string
  default     = "opentelemetry"
}

variable "opentelemetry_operator_set" {
  description = "Opentelemetry Operator helm value block with custom values to be merged with the values yaml"
  type        = any
  default     = []
}

variable "opentelemetry_operator_values" {
  description = "Opentelemetry Operator list of values in raw yaml to pass to helm. Values will be merged, in order, as Helm does with multiple `-f` options"
  type        = list(string)
  default     = [""]
}

variable "enable_clickhouse_operator" {
  description = "Install Clickhouse Operator"
  type        = bool
  default     = true
}

variable "clickhouse_operator_chart_version" {
  description = "Clickhouse Operator chart version"
  type        = string
  default     = null
}

variable "clickhouse_operator_namespace" {
  description = "Clickhouse Operator namespace"
  type        = string
  default     = "clickhouse"
}

variable "clickhouse_operator_set" {
  description = "Clickhouse Operator helm value block with custom values to be merged with the values yaml"
  type        = any
  default     = []
}

variable "clickhouse_operator_values" {
  description = "Clickhouse Operator list of values in raw yaml to pass to helm. Values will be merged, in order, as Helm does with multiple `-f` options"
  type        = list(string)
  default     = [""]
}

# MONITORING

variable "enable_qryn" {
  description = "Install Qryn"
  type        = bool
  default     = true
}

variable "qryn_chart_version" {
  description = "Qryn chart version"
  type        = string
  default     = null
}

variable "qryn_chart_name" {
  description = "Qryn chart name"
  type        = string
  default     = "qryn-helm"
}

variable "qryn_namespace" {
  description = "Qryn namespace"
  type        = string
  default     = "qryn"
}

variable "qryn_set" {
  description = "Qryn helm value block with custom values to be merged with the values yaml"
  type        = any
  default     = []
}

variable "qryn_values" {
  description = "Qryn list of values in raw yaml to pass to helm. Values will be merged, in order, as Helm does with multiple `-f` options"
  type        = list(string)
  default     = [""]
}

variable "qryn_clickhouse_chart_version" {
  description = "Qryn Clickhouse chart version"
  type        = string
  default     = null
}

variable "qryn_clickhouse_chart_name" {
  description = "Qryn Clickhouse chart name"
  type        = string
  default     = "qryn-helm"
}

variable "qryn_clickhouse_set" {
  description = "Qryn Clickhouse helm value block with custom values to be merged with the values yaml"
  type        = any
  default     = []
}

variable "qryn_clickhouse_values" {
  description = "Qryn Clickhouse list of values in raw yaml to pass to helm. Values will be merged, in order, as Helm does with multiple `-f` options"
  type        = list(string)
  default     = [""]
}

variable "enable_openobserve" {
  description = "Install Openobserve"
  type        = bool
  default     = false
}

variable "openobserve_chart_version" {
  description = "Openobserve chart version"
  type        = string
  default     = null
}

variable "openobserve_chart_name" {
  description = "Openobserve chart name like openobserve-standalone or openobserve"
  type        = string
  default     = "openobserve-standalone"
}

variable "openobserve_namespace" {
  description = "Openobserve namespace"
  type        = string
  default     = "openobserve"
}

variable "openobserve_set" {
  description = "Openobserve helm value block with custom values to be merged with the values yaml"
  type        = any
  default     = []
}

variable "openobserve_values" {
  description = "Openobserve list of values in raw yaml to pass to helm. Values will be merged, in order, as Helm does with multiple `-f` options"
  type        = list(string)
  default     = [""]
}

variable "enable_openobserve_collector" {
  description = "Install Openobserve Collector"
  type        = bool
  default     = false
}

variable "openobserve_collector_chart_version" {
  description = "Openobserve Collector chart version"
  type        = string
  default     = null
}

variable "openobserve_collector_namespace" {
  description = "Openobserve Collector namespace"
  type        = string
  default     = "openobserve-collector"
}

variable "openobserve_collector_set" {
  description = "Openobserve Collector helm value block with custom values to be merged with the values yaml"
  type        = any
  default     = []
}

variable "openobserve_collector_values" {
  description = "Openobserve Collector list of values in raw yaml to pass to helm. Values will be merged, in order, as Helm does with multiple `-f` options"
  type        = list(string)
  default     = [""]
}

# DASHBOARD

variable "enable_kubernetes_dashboard" {
  description = "Install Kubernetes Dashboard"
  type        = bool
  default     = true
}

variable "kubernetes_dashboard_chart_version" {
  description = "Kubernetes Dashboard chart version"
  type        = string
  default     = null
}

variable "kubernetes_dashboard_namespace" {
  description = "Kubernetes Dashboard namespace"
  type        = string
  default     = "kubernetes-dashboard"
}

variable "kubernetes_dashboard_set" {
  description = "Kubernetes Dashboard helm value block with custom values to be merged with the values yaml"
  type        = any
  default     = []
}

variable "kubernetes_dashboard_values" {
  description = "Kubernetes Dashboard list of values in raw yaml to pass to helm. Values will be merged, in order, as Helm does with multiple `-f` options"
  type        = list(string)
  default     = [""]
}
