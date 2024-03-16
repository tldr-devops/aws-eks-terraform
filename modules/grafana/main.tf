locals {
  admin_password = coalesce(var.admin_password, random_password.grafana_admin_password.result)

  # https://github.com/grafana/helm-charts/blob/main/charts/grafana/values.yaml
  values = [
    <<-EOT
      persistence:
        enabled: true
        size: 1Gi
      admin:
        existingSecret: "grafana-admin-credentials"
        userKey: username
        passwordKey: password
    EOT
  ]
}

resource "random_password" "grafana_admin_password" {
  length           = 32
  special          = true
}

module "kubernetes_manifests" {
  source = "../kubernetes-manifests"

  create        = var.create
  name          = "grafana-${var.namespace}-manifests"
  namespace     = var.namespace
  tags          = var.tags

  values = [
    <<-EOT
    resources:
      - kind: Secret
        apiVersion: v1
        metadata:
          name: "grafana-admin-credentials"
          namespace: "${var.namespace}"
        stringData:
          username: "${var.admin_user}"
          password: "${local.admin_password}"
        type: Opaque
      - kind: Secret
        apiVersion: v1
        metadata:
          name: "grafana-admin-credentials"
          namespace: "${var.namespace}"
        stringData:
          username: "${var.admin_user}"
          password: "${local.admin_password}"
        type: Opaque
    EOT
  ]
}

module "grafana" {
  source = "aws-ia/eks-blueprints-addon/aws"
  version = "~> 1.1"

  values = concat(
    local.values,
    var.values
  )
  set = var.set

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

# https://grafana.github.io/grafana-operator/docs/grafana/#external-grafana-instances
module "grafana_operator_datasource" {
  source = "../kubernetes-manifests"
  count = var.grafana_operator_integration == true ? 1 : 0

  name          = "grafana-${var.namespace}-integration"
  namespace     = var.grafana_operator_namespace
  tags          = var.tags

  values = [
    <<-EOT
    resources:
      - kind: Secret
        apiVersion: v1
        metadata:
          name: "grafana-${var.namespace}-integration-credentials"
          namespace: "${var.grafana_operator_namespace}"
        stringData:
          username: "${var.admin_user}"
          password: "${local.admin_password}"
        type: Opaque
      - apiVersion: "grafana.integreatly.org/v1beta1"
        kind: "Grafana"
        metadata:
          name: "grafana-${var.namespace}"
          namespace: "${var.namespace}"
          labels:
            dashboards: "grafana"
        spec:
          external:
            url: "http://${module.grafana.name}.${module.grafana.namespace}.svc.cluster.local"
            adminPassword:
              name: "grafana-${var.namespace}-integration-credentials"
              key: "password"
            adminUser:
              name: "grafana-${var.namespace}-integration-credentials"
              key: "username"
    EOT
  ]
}
