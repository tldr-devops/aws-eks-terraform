locals {
  admin_password = coalesce(var.admin_password, random_password.grafana_admin_password.result)

  # https://github.com/grafana/helm-charts/blob/main/charts/grafana/values.yaml
  values = [
    <<-EOT
      persistence:
        enabled: true
        size: 1Gi
      admin:
        existingSecret: "${kubernetes_secret.grafana_admin_credentials.metadata[0].name}"
        userKey: username
        passwordKey: password
    EOT
  ]
}

resource "random_password" "grafana_admin_password" {
  length           = 32
  special          = true
}

data "kubernetes_namespace" "grafana" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_namespace" "grafana" {
  count = var.create_namespace && ! (length(data.kubernetes_namespace.grafana) > 0) ? 1 : 0

  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "grafana_admin_credentials" {

  depends_on = [
    kubernetes_namespace.grafana
  ]

  metadata {
    generate_name = "grafana-admin-credentials"
    namespace     = var.namespace
  }

  data = {
    username = var.admin_user
    password = local.admin_password
  }
}

resource "kubernetes_secret" "grafana_operator_integration_credentials" {
  count = var.grafana_operator_integration == true ? 1 : 0

  metadata {
    generate_name = "grafana-${var.namespace}-integration-credentials"
    namespace     = var.grafana_operator_namespace
  }

  data = {
    username = var.admin_user
    password = local.admin_password
  }
}

# https://grafana.github.io/grafana-operator/docs/grafana/#external-grafana-instances
# resource "kubernetes_manifest" "grafana_operator_integration" {
#   count = var.grafana_operator_integration == true ? 1 : 0
# 
#   manifest = {
#     apiVersion = "grafana.integreatly.org/v1beta1"
#     kind = "Grafana"
#     metadata = {
#       name = "grafana-${var.namespace}"
#       namespace = var.namespace
#       labels = {
#         dashboards = "grafana"
#       }
#     }
#     spec = {
#       external = {
#         url = "http://${module.grafana.name}.${module.grafana.namespace}.svc.cluster.local"
#         adminPassword = {
#           name = "${kubernetes_secret.grafana_operator_integration_credentials[0].metadata[0].name}"
#           key = "password"
#         }
#         adminUser = {
#           name = "${kubernetes_secret.grafana_operator_integration_credentials[0].metadata[0].name}"
#           key = "username"
#         }
#       }
#     }
#   }
# }

# https://grafana.github.io/grafana-operator/docs/grafana/#external-grafana-instances
module "kubernetes_manifests" {
  source = "../kubernetes-manifests"
  count = var.grafana_operator_integration == true ? 1 : 0

#   depends_on = [
#     module.grafana,
#     kubernetes_secret.grafana_operator_integration_credentials
#   ]

  name          = "grafana-${var.namespace}-integration"
  namespace     = var.grafana_operator_namespace
  tags          = var.tags

  values = [
    <<-EOT
    resources:
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
              name: "${kubernetes_secret.grafana_operator_integration_credentials[0].metadata[0].name}"
              key: "password"
            adminUser:
              name: "${kubernetes_secret.grafana_operator_integration_credentials[0].metadata[0].name}"
              key: "username"
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
