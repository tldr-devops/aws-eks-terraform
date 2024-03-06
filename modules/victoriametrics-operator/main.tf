data "aws_region" "current" {}

locals {

  # https://github.com/VictoriaMetrics/helm-charts/blob/master/charts/victoria-metrics-operator/values.yaml
  values = [
    <<-EOT
      operator:
        # -- By default, operator converts prometheus-operator objects.
        disable_prometheus_converter: false
        # -- Compare-options and sync-options for prometheus objects converted by operator for properly use with ArgoCD
        prometheus_converter_add_argocd_ignore_annotations: true
        # -- By default, operator doesn't create psp for its objects.
        psp_auto_creation_enabled: false
        # -- Enables ownership reference for converted prometheus-operator objects,
        # it will remove corresponding victoria-metrics objects in case of deletion prometheus one.
        enable_converter_ownership: true
        # -- Enables custom config-reloader, bundled with operator.
        # It should reduce  vmagent and vmauth config sync-time and make it predictable.
        useCustomConfigReloader: true
      serviceMonitor:
        enabled: false
    EOT
  ]
  set = []

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

module "prometheus_operator_crds" {
  source = "aws-ia/eks-blueprints-addon/aws"
  version = "~> 1.1"

  set = var.prometheus_operator_crds_set
  values = var.prometheus_operator_crds_values

  create = var.create
  tags = var.tags
  create_release = var.prometheus_operator_crds_create_release
  name = var.prometheus_operator_crds_name
  description = var.prometheus_operator_crds_description
  namespace = var.namespace
  create_namespace = var.prometheus_operator_crds_create_namespace
  chart = var.prometheus_operator_crds_chart
  chart_version = var.prometheus_operator_crds_chart_version
  repository = var.prometheus_operator_crds_repository
  timeout = var.prometheus_operator_crds_timeout
  repository_key_file = var.prometheus_operator_crds_repository_key_file
  repository_cert_file = var.prometheus_operator_crds_repository_cert_file
  repository_ca_file = var.prometheus_operator_crds_repository_ca_file
  repository_username = var.prometheus_operator_crds_repository_username
  repository_password = var.prometheus_operator_crds_repository_password
  devel = var.prometheus_operator_crds_devel
  verify = var.prometheus_operator_crds_verify
  keyring = var.prometheus_operator_crds_keyring
  disable_webhooks = var.prometheus_operator_crds_disable_webhooks
  reuse_values = var.prometheus_operator_crds_reuse_values
  reset_values = var.prometheus_operator_crds_reset_values
  force_update = var.prometheus_operator_crds_force_update
  recreate_pods = var.prometheus_operator_crds_recreate_pods
  cleanup_on_fail = var.prometheus_operator_crds_cleanup_on_fail
  max_history = var.prometheus_operator_crds_max_history
  atomic = var.prometheus_operator_crds_atomic
  skip_crds = var.prometheus_operator_crds_skip_crds
  render_subchart_notes = var.prometheus_operator_crds_render_subchart_notes
  disable_openapi_validation = var.prometheus_operator_crds_disable_openapi_validation
  wait = var.prometheus_operator_crds_wait
  wait_for_jobs = var.prometheus_operator_crds_wait_for_jobs
  dependency_update = var.prometheus_operator_crds_dependency_update
  replace = var.prometheus_operator_crds_replace
  lint = var.prometheus_operator_crds_lint
  postrender = var.prometheus_operator_crds_postrender
  set_sensitive = var.prometheus_operator_crds_set_sensitive
  set_irsa_names = var.prometheus_operator_crds_set_irsa_names
}
