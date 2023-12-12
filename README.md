# aws-eks-terraform

[![#StandWithBelarus](https://img.shields.io/badge/Belarus-red?label=%23%20Stand%20With&labelColor=white&color=red)
<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Presidential_Standard_of_Belarus_%28fictional%29.svg/240px-Presidential_Standard_of_Belarus_%28fictional%29.svg.png" width="20" height="20" alt="Voices From Belarus" />](https://bysol.org/en/) [![Stand With Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/badges/StandWithUkraine.svg)](https://vshymanskyy.github.io/StandWithUkraine)

Setup basic EKS cluster with necessary controllers. Examples for further configuring the EKS cluster can be found in [eks blueprints](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main), [tEKS](https://github.com/particuleio/teks) and [eks demo](https://github.com/awslabs/eksdemo) repos.

## Depend on
- terraform
- helm
- kubectl
- [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks)
- [aws-ia/eks-blueprints-addons/aws](https://github.com/aws-ia/terraform-aws-eks-blueprints-addons)

## Example
```
cd example
terraform init
terraform apply -target=module.vpc
terraform apply
```

## Variables

## Outputs

| Name | Description |
|------|-------------|
|region|The AWS region|
|vpc_id|The ID of the target VPC|
|cluster_name|The name of the EKS|
|cluster_endpoint|Endpoint for your Kubernetes API server|
|cluster_certificate_authority_data|Base64 encoded certificate data required to communicate with the cluster|

Also `~/.kube/eks-${data.aws_region.current"}-${module.eks.cluster_name}` will be created by `aws eks` utility.

## About the Author

Hello, everyone! My name is Filipp, and I have been working with high load distribution systems and services, security, monitoring, continuous deployment and release management (DevOps domain) since 2012.

One of my passions is developing DevOps solutions and contributing to the open-source community. By sharing my knowledge and experiences, I strive to save time for both myself and others while fostering a culture of collaboration and learning.

I had to leave my home country, Belarus, due to my participation in [protests against the oppressive regime of dictator Lukashenko](https://en.wikipedia.org/wiki/2020%E2%80%932021_Belarusian_protests), who maintains a close affiliation with Putin. Since then, I'm trying to build my life from zero in other countries.

If you are seeking a skilled DevOps lead or architect to enhance your project, I invite you to connect with me on [LinkedIn](https://www.linkedin.com/in/filipp-frizzy-289a0360/) or explore my valuable contributions on [GitHub](https://github.com/Friz-zy/). Let's collaborate and create some cool solutions together :)

## Support

You can support this or any other of my projects
  - [![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/filipp_frizzy)
  - [donationalerts.com/r/filipp_frizzy](https://www.donationalerts.com/r/filipp_frizzy)
  - ETH 0xCD9fC1719b9E174E911f343CA2B391060F931ff7
  - BTC bc1q8fhsj24f5ncv3995zk9v3jhwwmscecc6w0tdw3

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
