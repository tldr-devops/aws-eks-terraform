## Problems with taints and tolerations

$ kubectl get all --all-namespaces
NAMESPACE        NAME                                                                READY   STATUS    RESTARTS      AGE
cert-manager     pod/cert-manager-cainjector-6994f8b485-hwtb5                        0/1     Pending   0             5m15s
cert-manager     pod/cert-manager-f4cdc8b95-chqgb                                    1/1     Running   0             5m15s
cert-manager     pod/cert-manager-startupapicheck-mqgmx                              0/1     Pending   0             5m8s
cert-manager     pod/cert-manager-webhook-7dd5f98779-56kk7                           0/1     Pending   0             5m15s
clickhouse       pod/altinity-clickhouse-operator-6c64dbbd87-wh5xn                   2/2     Running   0             5m49s
ingress-apisix   pod/apisix-ingress-controller-75579d89db-f6xx8                      2/2     Running   0             4m49s
kube-system      pod/aws-node-k5slj                                                  2/2     Running   0             5m12s
kube-system      pod/aws-node-qx5nk                                                  2/2     Running   0             5m12s
kube-system      pod/cluster-autoscaler-aws-cluster-autoscaler-6549cd7cc9-g92hr      1/1     Running   2 (48s ago)   5m17s
kube-system      pod/coredns-6556f9967c-vt4m8                                        0/1     Pending   0             9m21s
kube-system      pod/coredns-6556f9967c-xghnh                                        0/1     Pending   0             9m21s
kube-system      pod/efs-csi-controller-56f9b4cb75-4tjfb                             0/3     Pending   0             5m7s
kube-system      pod/efs-csi-controller-56f9b4cb75-5jhgh                             0/3     Pending   0             5m7s
kube-system      pod/efs-csi-node-hmlg7                                              3/3     Running   0             5m7s
kube-system      pod/efs-csi-node-x5vdk                                              3/3     Running   0             5m7s
kube-system      pod/kube-proxy-nvl8j                                                1/1     Running   0             5m12s
kube-system      pod/kube-proxy-w4fhw                                                1/1     Running   0             5m12s
kube-system      pod/metrics-server-7b674c55cd-lrcwx                                 1/1     Running   0             5m57s
monitoring       pod/clickhouse-shard0-0                                             0/1     Pending   0             5m
monitoring       pod/grafana-6fbfd67f58-w5zzf                                        0/1     Pending   0             4m48s
monitoring       pod/grafana-operator-65cb95cf84-5h2n6                               0/1     Pending   0             5m44s
monitoring       pod/postgresql-0                                                    0/1     Pending   0             6m21s
monitoring       pod/uptrace-0                                                       0/1     Running   4 (38s ago)   4m38s
monitoring       pod/vector-hx87m                                                    1/1     Running   0             4m14s
monitoring       pod/vector-sgx22                                                    1/1     Running   0             4m14s
monitoring       pod/victoria-metrics-auth-574d6768dc-5n5d6                          1/1     Running   0             4m42s
monitoring       pod/victoria-metrics-k8s-stack-kube-state-metrics-889cfcf97-dp6vt   0/1     Pending   0             3m36s
monitoring       pod/victoria-metrics-k8s-stack-prometheus-node-exporter-4kx8q       1/1     Running   0             3m36s
monitoring       pod/victoria-metrics-k8s-stack-prometheus-node-exporter-kwktx       1/1     Running   0             3m36s
monitoring       pod/victoria-metrics-operator-7696c74986-hsrt9                      1/1     Running   0             6m11s
monitoring       pod/vmagent-victoria-metrics-k8s-stack-587bc5f9d8-ptwx2             0/2     Pending   0             3m35s
monitoring       pod/vmalert-victoria-metrics-k8s-stack-6b9496f4f-w4vc2              0/2     Pending   0             3m35s
monitoring       pod/vmalertmanager-victoria-metrics-k8s-stack-0                     0/2     Pending   0             3m34s
monitoring       pod/vmsingle-victoria-metrics-k8s-stack-59d857bcd4-qth8j            0/1     Pending   0             3m34s
vpa              pod/vpa-certgen-2ldq7                                               0/1     Pending   0             6m2s

NAMESPACE        NAME                                                          TYPE           CLUSTER-IP       EXTERNAL-IP                                                                     PORT(S)                                                 AGE
cert-manager     service/cert-manager                                          ClusterIP      172.20.188.106   <none>                                                                          9402/TCP                                                5m16s
cert-manager     service/cert-manager-webhook                                  ClusterIP      172.20.140.65    <none>                                                                          443/TCP                                                 5m16s
clickhouse       service/altinity-clickhouse-operator-metrics                  ClusterIP      172.20.70.72     <none>                                                                          8888/TCP,9999/TCP                                       5m51s
default          service/kubernetes                                            ClusterIP      172.20.0.1       <none>                                                                          443/TCP                                                 11m
ingress-apisix   service/apisix-ingress-controller                             ClusterIP      172.20.125.37    <none>                                                                          80/TCP                                                  4m51s
ingress-apisix   service/apisix-ingress-controller-apisix-gateway              LoadBalancer   172.20.161.48    a1c9921f842c8450e8b1e1574ef38cf1-271ad5015e278428.elb.us-east-2.amazonaws.com   80:30542/TCP,443:32718/TCP                              4m51s
kube-system      service/cluster-autoscaler-aws-cluster-autoscaler             ClusterIP      172.20.198.197   <none>                                                                          8085/TCP                                                5m18s
kube-system      service/kube-dns                                              ClusterIP      172.20.0.10      <none>                                                                          53/UDP,53/TCP,9153/TCP                                  9m22s
kube-system      service/metrics-server                                        ClusterIP      172.20.125.202   <none>                                                                          443/TCP                                                 5m58s
kube-system      service/victoria-metrics-k8s-stack-coredns                    ClusterIP      None             <none>                                                                          9153/TCP                                                3m37s
kube-system      service/victoria-metrics-k8s-stack-kube-controller-manager    ClusterIP      None             <none>                                                                          10257/TCP                                               3m37s
kube-system      service/victoria-metrics-k8s-stack-kube-etcd                  ClusterIP      None             <none>                                                                          2379/TCP                                                3m37s
kube-system      service/victoria-metrics-k8s-stack-kube-scheduler             ClusterIP      None             <none>                                                                          10259/TCP                                               3m37s
monitoring       service/clickhouse                                            ClusterIP      172.20.195.193   <none>                                                                          8123/TCP,9000/TCP,9004/TCP,9005/TCP,9009/TCP,8001/TCP   5m1s
monitoring       service/clickhouse-headless                                   ClusterIP      None             <none>                                                                          8123/TCP,9000/TCP,9004/TCP,9005/TCP,9009/TCP            5m1s
monitoring       service/grafana                                               ClusterIP      172.20.31.191    <none>                                                                          80/TCP                                                  4m50s
monitoring       service/postgresql                                            ClusterIP      172.20.4.182     <none>                                                                          5432/TCP                                                6m23s
monitoring       service/postgresql-hl                                         ClusterIP      None             <none>                                                                          5432/TCP                                                6m23s
monitoring       service/uptrace                                               ClusterIP      172.20.186.254   <none>                                                                          14318/TCP,14317/TCP                                     4m40s
monitoring       service/vector                                                ClusterIP      172.20.55.82     <none>                                                                          8686/TCP,9090/TCP                                       4m15s
monitoring       service/vector-headless                                       ClusterIP      None             <none>                                                                          8686/TCP,9090/TCP                                       4m15s
monitoring       service/victoria-metrics-auth                                 ClusterIP      172.20.98.223    <none>                                                                          8427/TCP                                                4m43s
monitoring       service/victoria-metrics-k8s-stack-kube-state-metrics         ClusterIP      172.20.254.105   <none>                                                                          8080/TCP                                                3m37s
monitoring       service/victoria-metrics-k8s-stack-prometheus-node-exporter   ClusterIP      172.20.48.253    <none>                                                                          9100/TCP                                                3m37s
monitoring       service/victoria-metrics-operator                             ClusterIP      172.20.217.40    <none>                                                                          8080/TCP,443/TCP                                        6m12s
monitoring       service/vmsingle-victoria-metrics-k8s-stack                   ClusterIP      172.20.183.61    <none>                                                                          8429/TCP                                                3m35s

NAMESPACE     NAME                                                                 DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                                                  AGE
kube-system   daemonset.apps/aws-node                                              2         2         2       2            2           <none>                                                         9m21s
kube-system   daemonset.apps/efs-csi-node                                          2         2         2       2            2           kubernetes.io/os=linux                                         5m8s
kube-system   daemonset.apps/kube-proxy                                            2         2         2       2            2           <none>                                                         9m23s
monitoring    daemonset.apps/vector                                                2         2         2       2            2           kubernetes.io/os=linux,node.kubernetes.io/purpose=management   4m15s
monitoring    daemonset.apps/victoria-metrics-k8s-stack-prometheus-node-exporter   2         2         2       2            2           kubernetes.io/os=linux                                         3m37s

NAMESPACE        NAME                                                            READY   UP-TO-DATE   AVAILABLE   AGE
cert-manager     deployment.apps/cert-manager                                    1/1     1            1           5m16s
cert-manager     deployment.apps/cert-manager-cainjector                         0/1     1            0           5m16s
cert-manager     deployment.apps/cert-manager-webhook                            0/1     1            0           5m16s
clickhouse       deployment.apps/altinity-clickhouse-operator                    1/1     1            1           5m50s
ingress-apisix   deployment.apps/apisix-ingress-controller                       1/1     1            1           4m50s
kube-system      deployment.apps/cluster-autoscaler-aws-cluster-autoscaler       1/1     1            1           5m18s
kube-system      deployment.apps/coredns                                         0/2     2            0           9m22s
kube-system      deployment.apps/efs-csi-controller                              0/2     2            0           5m8s
kube-system      deployment.apps/metrics-server                                  1/1     1            1           5m58s
monitoring       deployment.apps/grafana                                         0/1     1            0           4m49s
monitoring       deployment.apps/grafana-operator                                0/1     1            0           5m45s
monitoring       deployment.apps/victoria-metrics-auth                           1/1     1            1           4m43s
monitoring       deployment.apps/victoria-metrics-k8s-stack-kube-state-metrics   0/1     1            0           3m37s
monitoring       deployment.apps/victoria-metrics-operator                       1/1     1            1           6m12s
monitoring       deployment.apps/vmagent-victoria-metrics-k8s-stack              0/1     1            0           3m36s
monitoring       deployment.apps/vmalert-victoria-metrics-k8s-stack              0/1     1            0           3m36s
monitoring       deployment.apps/vmsingle-victoria-metrics-k8s-stack             0/1     1            0           3m35s

NAMESPACE        NAME                                                                      DESIRED   CURRENT   READY   AGE
cert-manager     replicaset.apps/cert-manager-cainjector-6994f8b485                        1         1         0       5m17s
cert-manager     replicaset.apps/cert-manager-f4cdc8b95                                    1         1         1       5m17s
cert-manager     replicaset.apps/cert-manager-webhook-7dd5f98779                           1         1         0       5m17s
clickhouse       replicaset.apps/altinity-clickhouse-operator-6c64dbbd87                   1         1         1       5m51s
ingress-apisix   replicaset.apps/apisix-ingress-controller-75579d89db                      1         1         1       4m51s
kube-system      replicaset.apps/cluster-autoscaler-aws-cluster-autoscaler-6549cd7cc9      1         1         1       5m19s
kube-system      replicaset.apps/coredns-6556f9967c                                        2         2         0       9m23s
kube-system      replicaset.apps/efs-csi-controller-56f9b4cb75                             2         2         0       5m9s
kube-system      replicaset.apps/metrics-server-7b674c55cd                                 1         1         1       5m59s
monitoring       replicaset.apps/grafana-6fbfd67f58                                        1         1         0       4m50s
monitoring       replicaset.apps/grafana-operator-65cb95cf84                               1         1         0       5m46s
monitoring       replicaset.apps/victoria-metrics-auth-574d6768dc                          1         1         1       4m44s
monitoring       replicaset.apps/victoria-metrics-k8s-stack-kube-state-metrics-889cfcf97   1         1         0       3m38s
monitoring       replicaset.apps/victoria-metrics-operator-7696c74986                      1         1         1       6m13s
monitoring       replicaset.apps/vmagent-victoria-metrics-k8s-stack-587bc5f9d8             1         1         0       3m37s
monitoring       replicaset.apps/vmalert-victoria-metrics-k8s-stack-6b9496f4f              1         1         0       3m37s
monitoring       replicaset.apps/vmsingle-victoria-metrics-k8s-stack-59d857bcd4            1         1         0       3m36s

NAMESPACE    NAME                                                         READY   AGE
monitoring   statefulset.apps/clickhouse-shard0                           0/1     5m2s
monitoring   statefulset.apps/postgresql                                  0/1     6m24s
monitoring   statefulset.apps/uptrace                                     0/1     4m40s
monitoring   statefulset.apps/vmalertmanager-victoria-metrics-k8s-stack   0/1     3m36s

NAMESPACE      NAME                                     COMPLETIONS   DURATION   AGE
cert-manager   job.batch/cert-manager-startupapicheck   0/1           5m11s      5m11s
vpa            job.batch/vpa-certgen                    0/1           6m6s       6m6s

## update opentelemetry-operator

 Error: execution error at (opentelemetry-operator/templates/NOTES.txt:2:3): [ERROR] 'manager.collectorImage.repository' must be set. See https://github.com/open-telemetry/opentelemetry-helm-charts/blob/main/charts/opentelemetry-operator/UPGRADING.md for instructions.
│ 
│   with module.eks.module.opentelemetry_operator[0].module.opentelemetry_operator.helm_release.this[0],
│   on .terraform/modules/eks.opentelemetry_operator.opentelemetry_operator/main.tf line 9, in resource "helm_release" "this":
│    9: resource "helm_release" "this" {

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
