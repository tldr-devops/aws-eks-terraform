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
      AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
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

variable "enable_ingress_apisix" {
  description = "Install latest ingress Apisix"
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
