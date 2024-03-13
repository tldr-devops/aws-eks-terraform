data "aws_region" "current" {}

locals {
  grafana_admin_password = coalesce(var.grafana_admin_password, random_password.grafana_admin_password.result)
  auth_vmagent_rw_password = coalesce(var.auth_vmagent_rw_password, random_password.auth_vmagent_rw_password.result)
  auth_vmagent_rw_user = "agent"

  # https://github.com/VictoriaMetrics/helm-charts/blob/72ae97b4cfb27797928952d2bb0a3f3ecc146cee/charts/victoria-metrics-k8s-stack/values.yaml
  values = [
    <<-EOT
      vmsingle:
        enabled: true
        # spec for VMSingle crd
        # https://docs.victoriametrics.com/operator/api.html#vmsinglespec
        spec:
          retentionPeriod: "14"
          replicaCount: 1
          extraArgs: {}
          storage:
            accessModes:
              - ReadWriteOnce
            resources:
              requests:
                storage: 10Gi
      vmcluster:
        enabled: false
        # spec for VMCluster crd
        # https://docs.victoriametrics.com/operator/api.html#vmclusterspec
        spec:
          retentionPeriod: "14"
          replicationFactor: 2
          vmstorage:
            replicaCount: 2
            storageDataPath: "/vm-data"
            storage:
              volumeClaimTemplate:
                spec:
                  resources:
                    requests:
                      storage: 10Gi
      grafana:
        persistence:
          enabled: true
          size: 1Gi
        admin:
          existingSecret: "${kubernetes_secret.grafana_admin_credentials.metadata[0].name}"
          userKey: username
          passwordKey: password
    EOT
  ]
  set = []

  # https://github.com/VictoriaMetrics/helm-charts/blob/1e41a73904dbaed41748ddb724674c94cbfa2fd6/charts/victoria-metrics-auth/values.yaml
  # https://docs.victoriametrics.com/vmauth/
  auth_values = [
    <<-EOT
      serviceMonitor:
        enabled: true
      secretName: "${kubernetes_secret.auth_config.metadata[0].name}"
    EOT
  ]
  auth_set = []

}

resource "random_password" "grafana_admin_password" {
  length           = 32
  special          = true
}

resource "random_password" "auth_vmagent_rw_password" {
  length           = 32
  special          = true
}

data "kubernetes_namespace" "victoriametrics" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_namespace" "victoriametrics" {
  count = var.create_namespace && ! (length(data.kubernetes_namespace.victoriametrics) > 0) ? 1 : 0

  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "grafana_admin_credentials" {

  depends_on = [
    kubernetes_namespace.victoriametrics
  ]

  metadata {
    generate_name = "victoriametrics-grafana-admin-credentials"
    namespace     = var.namespace
  }

  data = {
    username = var.grafana_admin_user
    password = local.grafana_admin_password
  }
}

resource "kubernetes_secret" "auth_config" {

  depends_on = [
    kubernetes_namespace.victoriametrics,
    module.victoriametrics,
    random_password.auth_vmagent_rw_password
  ]

  metadata {
    generate_name = "victoriametrics-auth-config"
    namespace     = var.namespace
  }

  data = {
    # https://docs.victoriametrics.com/vmauth/
    "auth.yml" = <<-EOT
      users:
        - username: "${local.auth_vmagent_rw_user}"
          password: "${local.auth_vmagent_rw_password}"
          url_prefix: "http://vmagent-${module.victoriametrics.chart}:8429/"
      EOT
  }
}

module "victoriametrics" {
  source = "aws-ia/eks-blueprints-addon/aws"
  version = "~> 1.1"

  set = var.set

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

module "auth" {
  source = "aws-ia/eks-blueprints-addon/aws"
  version = "~> 1.1"

  depends_on = [
    #module.victoriametrics,
    #kubernetes_secret.auth_config
  ]

  set = var.auth_set

  values = concat(
    local.auth_values,
    var.auth_values
  )

  create = var.create
  tags = var.tags
  create_release = var.auth_create_release
  name = var.auth_name
  description = var.auth_description
  namespace = var.namespace
  create_namespace = var.create_namespace
  chart = var.auth_chart
  chart_version = var.auth_chart_version
  repository = var.auth_repository
  timeout = var.auth_timeout
  repository_key_file = var.auth_repository_key_file
  repository_cert_file = var.auth_repository_cert_file
  repository_ca_file = var.auth_repository_ca_file
  repository_username = var.auth_repository_username
  repository_password = var.auth_repository_password
  devel = var.auth_devel
  verify = var.auth_verify
  keyring = var.auth_keyring
  disable_webhooks = var.auth_disable_webhooks
  reuse_values = var.auth_reuse_values
  reset_values = var.auth_reset_values
  force_update = var.auth_force_update
  recreate_pods = var.auth_recreate_pods
  cleanup_on_fail = var.auth_cleanup_on_fail
  max_history = var.auth_max_history
  atomic = var.auth_atomic
  skip_crds = var.auth_skip_crds
  render_subchart_notes = var.auth_render_subchart_notes
  disable_openapi_validation = var.auth_disable_openapi_validation
  wait = var.auth_wait
  wait_for_jobs = var.auth_wait_for_jobs
  dependency_update = var.auth_dependency_update
  replace = var.auth_replace
  lint = var.auth_lint
  postrender = var.auth_postrender
  set_sensitive = var.auth_set_sensitive
  set_irsa_names = var.auth_set_irsa_names
}
