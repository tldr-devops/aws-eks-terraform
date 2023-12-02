variable "vpc_id" {
  description = "ID of target VPC, 'default' will be used by default"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "List of networks for using for control plane and nodes"
  type    = list(string)
  default = null
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

variable "cluster_addons" {
  description = "AWS EKS cluster addons map, default is latest coredns, kube-proxy, vpc-cni, aws-ebs-csi-driver, snapshot-controller"
  type        = any
  default     = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
    snapshot-controller = {
      most_recent = true
    }
  }
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

    instance_types = ["m6a.large", "m5a.large", "m7i-flex.large"] # , "m6i.large", "m5.large", "m4.large", "m7i.large"] # 2cpu 8gb
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

variable "eks_managed_node_groups" {
  description = "Configs for eks_managed_node_groups"
  type        = any
  default     = {}
}

variable "fargate_profiles" {
  description = "Configs for fargate_profiles"
  type        = any
  default     = {}
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
