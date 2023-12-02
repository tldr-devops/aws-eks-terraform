# aws-eks-terraform

[![#StandWithBelarus](https://img.shields.io/badge/Belarus-red?label=%23%20Stand%20With&labelColor=white&color=red)
<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Presidential_Standard_of_Belarus_%28fictional%29.svg/240px-Presidential_Standard_of_Belarus_%28fictional%29.svg.png" width="20" height="20" alt="Voices From Belarus" />](https://bysol.org/en/) [![Stand With Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/badges/StandWithUkraine.svg)](https://vshymanskyy.github.io/StandWithUkraine)

Setup basic EKS cluster with necessary controllers. Examples for further configuring the EKS cluster can be found in [eks blueprints](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main), [tEKS](https://github.com/particuleio/teks) and [eks demo](https://github.com/awslabs/eksdemo) repos.

## Depend on
- terraform
- helm
- kubectl
- [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks)

## Example
```

```

## Variables

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
|vpc_id|ID of target VPC, 'default' will be used by default|string|no|
|subnets_by_az|List of objects that contain subnets ids sorted by availability zones|list(object)|no|
|number_of_multi_az|How many availability zones should be used for running control plane and nodes|number|no|
|cluster_name|AWS EKS cluster name|string|yes|
|cluster_version|AWS EKS cluster version|string|no|
|cluster_addons|AWS EKS cluster addons map, default is latest coredns, kube-proxy, vpc-cni, aws-ebs-csi-driver, snapshot-controller|map(any)|no|
|self_managed_node_group_defaults|Defaults configs for self_managed_node_groups|any|no|
|eks_managed_node_group_defaults|Defaults configs for eks_managed_node_groups|any|no|
|fargate_profile_defaults|Defaults configs for fargate_profiles|any|no|
|group_defaults|Defaults configs for self_managed_node_groups, eks_managed_node_groups and fargate_profiles|any|no|
|self_managed_node_groups|Configs for self_managed_node_groups|any|no|
|self_managed_node_group_templates_for_multi_azTemplates for generating similar self managed node group in each availability zone|any|no|
|self_managed_node_group_number_of_multi_az|How many availability zones should be used for generating self managed node groups from template|number|no|
|eks_managed_node_groups|Configs for eks_managed_node_groups|any|no|
|eks_managed_node_group_templates_for_multi_az|Templates for generating similar eks managed node group in each availability zone|any|no|
|eks_managed_node_group_number_of_multi_az|How many availability zones should be used for generating eks managed node groups from template|number|no|
|fargate_profiles|Configs for fargate_profiles|any|no|
|fargate_profile_templates_for_multi_az|Templates for generating similar fargate profiles in each availability zone|any|no|
|fargate_profile_number_of_multi_az|How many availability zones should be used for generating fargate profiles from template|number|no|
|admin_iam_roles|List of account roles that should have EKS amdin permissions|list(string)|no|
|admin_iam_users|List of account users that should have EKS amdin permissions|list(string)|no|
|eks_iam_roles|List of maps with iam roles that should map eks service accounts|list(object)|no|
|enable_aws_efs_csi_driver|Install latest AWS EFS CSI driver|bool|no|
|aws_efs_csi_driver_config|AWS EFS CSI driver configuration|map|no|
|enable_aws_node_termination_handler|Install latest AWS node termination handler|bool|no|
|aws_node_termination_handler_config|AWS node termination handler configuration|map|no|
|enable_cert_manager|Install latest cert-manager|bool|no|
|cert_manager_config|Cert manager configuration|map|no|
|enable_cluster_autoscaler|Install latest cluster autoscaler|bool|no|
|cluster_autoscaler_config|Cluster autoscaler configuration|map|no|
|enable_metrics_server|Install latest metrics server|bool|no|
|metrics_server_config|Metrics server configuration|map|no|
|enable_vpa|Install latest Vertical Pod Autoscaler|bool|no|
|vpa_config|Vertical Pod Autoscaler configuration|map|no|
|tags|Tags for EKS|map(string)|no|

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
