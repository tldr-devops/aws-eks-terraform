# aws-eks-terraform

[![#StandWithBelarus](https://img.shields.io/badge/Belarus-red?label=%23%20Stand%20With&labelColor=white&color=red)
<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Presidential_Standard_of_Belarus_%28fictional%29.svg/240px-Presidential_Standard_of_Belarus_%28fictional%29.svg.png" width="20" height="20" alt="Voices From Belarus" />](https://bysol.org/en/) [![Stand With Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/badges/StandWithUkraine.svg)](https://vshymanskyy.github.io/StandWithUkraine)

Setup EKS cluster with necessary controllers, operators and monitoring stack. Similar projects:
- [eks blueprints](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main)
- [tEKS](https://github.com/particuleio/teks)
- [eks demo](https://github.com/awslabs/eksdemo)

## What is included

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

- email integration
- dns integration
- alert rules
- resources limits
- ci & cd integration
- network policies
- host-based pod segregation
- ...

## Depend on
- terraform
- aws cli
- kubectl
- [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks)
- [aws-ia/eks-blueprints-addons/aws](https://github.com/aws-ia/terraform-aws-eks-blueprints-addons)

This module contain local-exec block with `kubectl patch` for applying `tolerations` and `nodeSelector` deployments in `kube-system` namespace, that will work only in unix shell, so it will fail on Windows. This patch is necessary as some of eks addons currently doesn't support `tolerations` and `nodeSelector` in their configurations, but only necessary if you will use host nodes with taints to separate `management` processes from other. You can disable it by set `apply_kubectl_patch` variable to `false`.

## Example
```
cd example
terraform init
terraform apply -target=module.vpc
terraform apply
terraform output all
```

to destroy everything run (you may need to run it twice one by one)
```
terraform destroy -auto-approve
```

force destroy in case of problems
```
helm ls -a --all-namespaces | awk 'NR > 1 { print  "-n "$2, $1}' | xargs -L1 helm delete
kubectl delete all --all --all-namespaces
terraform destroy -auto-approve
```

After `terraform destroy` check ec2 volumes for unused disks as aws-ebs-csi-driver doesn't delete it by default after deleting helm releases.

## Security

`victoria-metrics-k8s-stack` deployed without internal password protection. Multiple charts such as `apisix`, `qryn` and `uptrace` contain explicit passwords in the values and do not use k8s secrets.

## Upgrading process

Helm upgrade `reset_values` flag set to `true` for everything except databases like postgresql and clickhouse, see this [explain](https://shipmight.com/blog/understanding-helm-upgrade-reset-reuse-values)

## Outputs

Check the [./example/outputs.example](./example/outputs.example) file to get an example of the output. For setting DNS you can describe ingress external address with kubectl: `kubectl get service/apisix-ingress-controller-apisix-gateway -n ingress-apisix`.

Also `~/.kube/eks-${account_id}-${region}-${cluster_name}` kubeconfig will be created by `aws eks` utility.

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
