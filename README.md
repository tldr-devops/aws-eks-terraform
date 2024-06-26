# aws-eks-terraform

[![#StandWithBelarus](https://img.shields.io/badge/Belarus-red?label=%23%20Stand%20With&labelColor=white&color=red)
<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Presidential_Standard_of_Belarus_%28fictional%29.svg/240px-Presidential_Standard_of_Belarus_%28fictional%29.svg.png" width="20" height="20" alt="Voices From Belarus" />](https://bysol.org/en/) [![Stand With Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/badges/StandWithUkraine.svg)](https://vshymanskyy.github.io/StandWithUkraine)

## Overview

This project provides a ready-to-use configuration for setting up an AWS EKS cluster with all necessary controllers, operators, and monitoring stack. By using this configuration, DevOps engineers can save 1-2 months of work.

### Key Features

- **Adaptation for small clusters**: Many modules, especially [Grafana monitoring stack](https://grafana.com/about/grafana-stack/), are created with the intention of being used in large clusters. I understand the pain of small projects, so I tried to create a setup that is as simple and efficient as possible. For example, [VictoriaMetrics](https://victoriametrics.com/) stack selected as best prometheus-like monitoring engine and [Uptrace](https://uptrace.dev/) with AWS S3 backend selected for long term metrics, logs and traces storage.
- **Node Group Templates**: Templates for creating Managed Node Groups and Fargate Profile linked to each availability zone individually.
- **Default Settings and Integration**: Reasonable default values and integration between modules for seamless setup.

Similar projects:
- [eks blueprints](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main)
- [tEKS](https://github.com/particuleio/teks)
- [eks demo](https://github.com/awslabs/eksdemo)

### Development Time

- [Filipp Frizzy](https://github.com/Friz-zy/): 181h 30m

## About the Author

I'm Filipp - a Lead DevOps Engineer with 12+ years of experience, currently based in Poland (UTC+2). I am open to work and considering Senior, Lead, or Architect DevOps roles with a B2B contract from $7k/month and 100% remote. I have extensive experience as a primary or lead DevOps engineer in product teams and startups. If you are looking for a DevOps engineer for a project, contact me on [LinkedIn](https://www.linkedin.com/in/filipp-frizzy-289a0360/).

From my side:
- Working as Ops and DevOps engineer since 2012, with over 7 years of experience with UK & US teams.
- Experience as Single, Main, or Lead DevOps for small teams of other Ops people.
- Migration of services into Docker environments, including Kubernetes, Docker Swarm, and AWS Elastic Containers.
- AWS is my primary cloud since 2015
- Proficient with GitLab, GitHub, Jenkins, ArgoCD, and FluxCD CI & CD.
- Writing Terraform, Terragrunt, Ansible, SaltStack, and other IaC setups.
- Solved several production disasters with various Kubernetes setups.
- Skilled in SQL and NoSQL HA setups, like Galera MySQL, MongoDB, Kafka, ZooKeeper, Clickhouse, Redis, etc.
- Developed many monitoring solutions with Prometheus, VictoriaMetrics, EFK, Zabbix, etc.
- Authored 2 open source projects with over 1k stars.

## Included Components

| Description | Purpose | Enabled | DNS |
| --- | --- | --- | --- |
|EKS cluster module based on [terraform-aws-modules/eks/aws](https://github.com/terraform-aws-modules/terraform-aws-eks) v19|Base|True||
|Templates for Managed Node Groups and Fargate Profile to link them to each availability zone instead of all zones at once|Base|True||
|Integration of modules with each other and reasonable default values|Base|True||
|[CoreDNS EKS addon](https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html)|Core|True||
|[Kube-Proxy EKS addon](https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html)|Core|True||
|[VPC CNI EKS addon](https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html)|Core|True||
|[AWS EBS CSI driver EKS addon](https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html)|Core|True||
|[Snapshot Controller EKS addon](https://docs.aws.amazon.com/eks/latest/userguide/csi-snapshot-controller.html)|Core|True||
|[AWS EFS CSI driver](https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/main/docs/addons/aws-efs-csi-driver.md)|Core|True||
|[AWS Node Termination Handler](https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/main/docs/addons/aws-node-termination-handler.md)|Core|True||
|[Cert Manager](https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/main/docs/addons/cert-manager.md)|Core|True||
|[Cluster Autoscaler](https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/main/docs/addons/cluster-autoscaler.md)|Core|True||
|[Metrics Server](https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/main/docs/addons/metrics-server.md)|Core|True||
|[Vertical Pod Autoscaler](https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/main/docs/addons/vertical-pod-autoscaler.md)|Core|True||
|[Ingress Apisix](https://github.com/apache/apisix-ingress-controller)|Ingress|True||
|[Ingress Nginx](https://github.com/kubernetes/ingress-nginx)|Ingress|False||
|[Victoriametrics Operator](https://github.com/VictoriaMetrics/operator)|Operator|True||
|[Opentelemetry Operator](https://github.com/open-telemetry/opentelemetry-operator)|Operator|False||
|[Clickhouse Operator](https://github.com/Altinity/clickhouse-operator)|Operator|False||
|[Grafana Operator](https://artifacthub.io/packages/helm/bitnami/grafana-operator)|Operator|True||
|[Victoriametrics](https://github.com/VictoriaMetrics/helm-charts/blob/master/charts/victoria-metrics-k8s-stack/README.md)|Monitoring|True|vmauth.${var.ingress_domain}<br>victoriametrics.${var.ingress_domain}<br>vmalertmanager.${var.ingress_domain}<br>vmagent.${var.ingress_domain}<br>vmalert.${var.ingress_domain}|
|[Grafana](https://grafana.com/oss/grafana/)|Monitoring|True|grafana.${var.ingress_domain}|
|[Uptrace](https://uptrace.dev/)|Monitoring|True|uptrace.${var.ingress_domain}|
|[Vector](https://vector.dev/)|Monitoring|True||
|[Qryn](https://qryn.metrico.in)|Monitoring|False|qryn.${var.ingress_domain}|
|[Openobserve](https://openobserve.ai/)|Monitoring|False|openobserve.${var.ingress_domain}|
|[Kubernetes Dashboard](https://github.com/kubernetes/dashboard)|Control|False|k8s-dashboard.${var.ingress_domain}|

## What is not included right now

- Email integration
- DNS integration
- Alert rules
- Resource limits
- CI & CD integration
- Network policies
- Host-based pod segregation

## Dependencies

- terraform
- aws cli
- kubectl
- [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks)
- [aws-ia/eks-blueprints-addons/aws](https://github.com/aws-ia/terraform-aws-eks-blueprints-addons)

This module contains a local-exec block with `kubectl patch` for applying `tolerations` and `nodeSelector` deployments in the `kube-system` namespace, which will only work in a Unix shell, and will fail on Windows. This patch is necessary as some EKS addons currently don't support `tolerations` and `nodeSelector` in their configurations, but it is only necessary if you use host nodes with taints to separate `management` processes from others. You can disable it by setting the `apply_kubectl_patch` variable to `false`.

## Example

```
cd example
terraform init
terraform apply -target=module.vpc
terraform apply
terraform output all
```

To destroy everything, run (you may need to run it twice):
```
terraform destroy -auto-approve
```

Force destroy in case of problems:
```
helm ls -a --all-namespaces | awk 'NR > 1 { print  "-n "$2, $1}' | xargs -L1 helm delete
kubectl delete all --all --all-namespaces
terraform destroy -auto-approve
```

After `terraform destroy`, check EC2 volumes for unused disks as the aws-ebs-csi-driver doesn't delete them by default after deleting helm releases.

## Security

`victoria-metrics-k8s-stack` is deployed without internal password protection. Multiple charts such as `apisix`, `qryn`, and `uptrace` contain explicit passwords in the values and do not use Kubernetes secrets.

## Upgrading Process

Helm upgrade `reset_values` flag is set to `true` for everything except databases like PostgreSQL and Clickhouse. See this [explanation](https://shipmight.com/blog/understanding-helm-upgrade-reset-reuse-values).

## Outputs

Check the [./example/outputs.example](./example/outputs.example) file to get an example of the output. For setting DNS, you can describe the ingress external address with `kubectl`:
```
kubectl get service/apisix-ingress-controller-apisix-gateway -n ingress-apisix
```

Additionally, a kubeconfig file `~/.kube/eks-${account_id}-${region}-${cluster_name}` will be created by the `aws eks` utility.

## Support

You can support this or any other of my projects:
- [![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/filipp_frizzy)
- [donationalerts.com/r/filipp_frizzy](https://www.donationalerts.com/r/filipp_frizzy)
- ETH 0xCD9fC1719b9E174E911f343CA2B391060F931ff7
- BTC bc1q8fhsj24f5ncv3995zk9v3jhwwmscecc6w0tdw3
