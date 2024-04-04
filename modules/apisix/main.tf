# https://github.com/apache/apisix-ingress-controller/blob/master/docs/en/latest/deployments/aws.md
# https://docs.google.com/spreadsheets/d/191WWNpjJ2za6-nbG4ZoUMXMpUK8KlCIosvQB0f-oq3k/edit#gid=907731238
# https://github.com/apache/apisix-helm-chart/blob/master/charts/apisix-ingress-controller/values.yaml

# https://apisix.apache.org/docs/ingress-controller/getting-started/
# https://navendu.me/series/hands-on-with-apache-apisix-ingress/

locals {
  # https://github.com/apache/apisix-helm-chart/blob/master/charts/apisix-ingress-controller/values.yaml
  values = [
    <<-EOT
      config:
        etcdserver:
          enabled: true
        apisix:
          # -- Enabling this value, overrides serviceName and serviceNamespace.
          clusterName: "default"
          # -- the APISIX admin API version. can be "v2" or "v3", default is "v2".
          adminAPIVersion: "v2"
          # -- The APISIX Helm chart supports storing user credentials in a secret.
          # The secret needs to contain a single key for admin token with key adminKey by default.
          existingSecret: "apisix-admin-password"
      gateway:
        # -- Apache APISIX service type for user access itself
        type: LoadBalancer
        annotations:
          service.beta.kubernetes.io/aws-load-balancer-type: nlb
        tls:
          enabled: true
    EOT
  ]
  set = []
}

resource "random_password" "apisix_admin_key" {
  length           = 32
  special          = false
}

module "kubernetes_manifests" {
  source = "../kubernetes-manifests"

  create        = var.create
  name          = "apisix-manifests"
  namespace     = var.namespace
  tags          = var.tags

  values = [
    <<-EOT
    resources:
      - kind: Secret
        apiVersion: v1
        metadata:
          name: "apisix-admin-password"
          namespace: "${var.namespace}"
        stringData:
          adminKey: "${random_password.apisix_admin_key.result}"
        type: Opaque
    EOT
  ]
}

module "ingress_apisix" {
  source = "aws-ia/eks-blueprints-addon/aws"
  version = "~> 1.1"

  set = concat(
    local.set,
    var.set
  )

  values = concat(
    local.values,
    var.values
  )

  create = var.create
  tags = var.tags
  create_release = var.create_release
  name = var.name
  description = var.description
  namespace = var.namespace
  create_namespace = var.create_namespace
  chart = var.chart
  chart_version = var.chart_version
  repository = var.repository
  timeout = var.timeout
  repository_key_file = var.repository_key_file
  repository_cert_file = var.repository_cert_file
  repository_ca_file = var.repository_ca_file
  repository_username = var.repository_username
  repository_password = var.repository_password
  devel = var.devel
  verify = var.verify
  keyring = var.keyring
  disable_webhooks = var.disable_webhooks
  reuse_values = var.reuse_values
  reset_values = var.reset_values
  force_update = var.force_update
  recreate_pods = var.recreate_pods
  cleanup_on_fail = var.cleanup_on_fail
  max_history = var.max_history
  atomic = var.atomic
  skip_crds = var.skip_crds
  render_subchart_notes = var.render_subchart_notes
  disable_openapi_validation = var.disable_openapi_validation
  wait = var.wait
  wait_for_jobs = var.wait_for_jobs
  dependency_update = var.dependency_update
  replace = var.replace
  lint = var.lint
  postrender = var.postrender
  set_sensitive = var.set_sensitive
  set_irsa_names = var.set_irsa_names
  create_role = var.create_role
  role_name = var.role_name
  role_name_use_prefix = var.role_name_use_prefix
  role_path = var.role_path
  role_permissions_boundary_arn = var.role_permissions_boundary_arn
  role_description = var.role_description
  role_policies = var.role_policies
  oidc_providers = var.oidc_providers
  max_session_duration = var.max_session_duration
  assume_role_condition_test = var.assume_role_condition_test
  allow_self_assume_role = var.allow_self_assume_role
  create_policy = var.create_policy
  source_policy_documents = var.source_policy_documents
  override_policy_documents = var.override_policy_documents
  policy_statements = var.policy_statements
  policy_name = var.policy_name
  policy_name_use_prefix = var.policy_name_use_prefix
  policy_path = var.policy_path
  policy_description = var.policy_description
}
