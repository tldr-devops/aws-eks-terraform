## Problem with fargate

efs-csi-controller-56f9b4cb75-6nt6l Pod not supported on Fargate: fields not supported: HostNetwork, port contains HostIP or HostPort
efs-csi-controller-56f9b4cb75-5hqmk 0/1 nodes are available: 1 node(s) had untolerated taint {eks.amazonaws.com/compute-type: fargate}.
efs-csi-controller-56f9b4cb75-bjrk7 0/1 nodes are available: 1 node(s) had untolerated taint {eks.amazonaws.com/compute-type: fargate}.

eks.amazonaws.com/compute-type	fargate

coredns Annotations eks.amazonaws.com/compute-type ec2; kube-system namespace
0/1 nodes are available: 1 node(s) had untolerated taint {eks.amazonaws.com/compute-type: fargate}. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..

aws-node-termination-handler-6885ff9f5c-8lkml 0/1 nodes are available: 1 node(s) had untolerated taint {node.cloudprovider.kubernetes.io/uninitialized: true}. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..

cert-manager-6b8949bd9f-4xjv6 works fine
cert-manager-webhook-7dd5f98779-4ptvk works fine

cert-manager-startupapicheck-zsjtj BackOff	a minute ago	kubelet	Back-off restarting failed container cert-manager-startupapicheck in pod

cluster-autoscaler-aws-cluster-autoscaler-55946f8cb6-9wxtb 0/1 nodes are available: 1 node(s) had untolerated taint {node.cloudprovider.kubernetes.io/uninitialized: true}. preemption: 0/1 nodes are available: 1 Preemption is not helpful fo

metrics-server-767bf8d8cb-kqzmn 0/1 nodes are available: 1 node(s) had untolerated taint {node.cloudprovider.kubernetes.io/uninitialized: true}.

vpa-certgen-4qqrb 0/1 nodes are available: 1 node(s) had untolerated taint {eks.amazonaws.com/compute-type: fargate}.

Error: creating EKS Fargate Profile (test:external-secrets_us-east-2b): operation error EKS: CreateFargateProfile, https response error StatusCode: 400, RequestID: d2c0004e-4394-4eba-8b7c-5842ba1f10da, ResourceLimitExceededException: Fargate Profile limit exceeded for cluster.

## Problem with tainted vm

cert-manager-cainjector-6994f8b485-8zn4t 0/1 nodes are available: 1 node(s) had untolerated taint {node.kubernetes.io/purpose: management}
cert-manager-startupapicheck-pj5xm 0/1 nodes are available: 1 node(s) had untolerated taint {node.kubernetes.io/purpose: management}
cert-manager-webhook-7dd5f98779-265rs 0/1 nodes are available: 1 node(s) had untolerated taint {node.kubernetes.io/purpose: management}

cluster-autoscaler-aws-cluster-autoscaler-74bb4b4ddd-7rd9t Back-off restarting failed container aws-cluster-autoscaler in pod cluster-autoscaler-aws-cluster-autoscaler-74bb4b4ddd-7rd9t_kube-system(3e8626f8-1f11-4e08-a115-b0bdd0ee6095)

coredns-664b6f5f5c-bl8tx 0/1 nodes are available: 1 node(s) had untolerated taint {node.kubernetes.io/purpose: management}
coredns-664b6f5f5c-h5jzw 0/1 nodes are available: 1 node(s) had untolerated taint {node.kubernetes.io/purpose: management}

efs-csi-controller-56f9b4cb75-hb6tq 0/1 nodes are available: 1 node(s) had untolerated taint {node.kubernetes.io/purpose: management}.
efs-csi-controller-56f9b4cb75-s6g2j 0/1 nodes are available: 1 node(s) had untolerated taint {node.kubernetes.io/purpose: management}

vpa-certgen-zkkzt 0/1 nodes are available: 1 node(s) had untolerated taint {node.kubernetes.io/purpose: management}.

## Problems with labels vm

╷
│ Error: creating IAM Policy (aws-node-termination-handler-2023121322583753120000001c): MalformedPolicyDocument: Policy statement must contain resources.
│       status code: 400, request id: 29a9eebd-7b9c-4d3a-9b91-c256b1514f93
│ 
│   with module.eks.module.addons.module.aws_node_termination_handler.aws_iam_policy.this[0],
│   on .terraform/modules/eks.addons.aws_node_termination_handler/main.tf line 242, in resource "aws_iam_policy" "this":
│  242: resource "aws_iam_policy" "this" {
│ 
╵
╷
│ Error: creating EKS Add-On (test:aws-ebs-csi-driver): operation error EKS: CreateAddon, https response error StatusCode: 400, RequestID: 898b8647-dfd0-4777-b599-5a41052a5b6c, InvalidParameterException: ConfigurationValue provided in request is not supported: Json schema validation failed with error: [$.nodeSelector: is not defined in the schema and the schema does not allow additional properties]
│ 
│   with module.eks.module.addons.aws_eks_addon.this["aws-ebs-csi-driver"],
│   on .terraform/modules/eks.addons/main.tf line 2177, in resource "aws_eks_addon" "this":
│ 2177: resource "aws_eks_addon" "this" {
│ 
╵
╷
│ Error: creating EKS Add-On (test:snapshot-controller): operation error EKS: CreateAddon, https response error StatusCode: 400, RequestID: fdbb7642-2f1e-4e1a-bea2-9074d9b03488, InvalidParameterException: ConfigurationValue provided in request is not supported: Json schema validation failed with error: [$.nodeSelector: is not defined in the schema and the schema does not allow additional properties]
│ 
│   with module.eks.module.addons.aws_eks_addon.this["snapshot-controller"],
│   on .terraform/modules/eks.addons/main.tf line 2177, in resource "aws_eks_addon" "this":
│ 2177: resource "aws_eks_addon" "this" {
│ 
╵
╷
│ Error: creating EKS Add-On (test:vpc-cni): operation error EKS: CreateAddon, https response error StatusCode: 400, RequestID: aaecec3f-34ca-4977-bf4e-993c4c382242, InvalidParameterException: ConfigurationValue provided in request is not supported: Json schema validation failed with error: [$.nodeSelector: is not defined in the schema and the schema does not allow additional properties]
│ 
│   with module.eks.module.addons.aws_eks_addon.this["vpc-cni"],
│   on .terraform/modules/eks.addons/main.tf line 2177, in resource "aws_eks_addon" "this":
│ 2177: resource "aws_eks_addon" "this" {
