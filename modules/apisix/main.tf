# https://github.com/apache/apisix-ingress-controller/blob/master/docs/en/latest/deployments/aws.md
# https://docs.google.com/spreadsheets/d/191WWNpjJ2za6-nbG4ZoUMXMpUK8KlCIosvQB0f-oq3k/edit#gid=907731238
# https://github.com/apache/apisix-helm-chart/blob/master/charts/apisix-ingress-controller/values.yaml

resource "random_password" "apisix_admin_key" {
  length           = 32
  special          = false
}

resource "random_password" "apisix_viewer_key" {
  length           = 32
  special          = false
}

module "ingress_apisix" {
  source = "aws-ia/eks-blueprints-addon/aws"
  version = "~> 1.1"

  set = concat(
    [
      {
        name  = "config.etcdserver.enabled"
        value = "true"
      },
      {
        name  = "gateway.type"
        value = "LoadBalancer"
      },
      {
        name  = "ingress-controller.enabled"
        value = "true"
      },
      {
        name  = "ingress-controller.config.apisix.serviceNamespace"
        value = var.namespace
      },
      {
        name  = "ingress-controller.config.apisix.adminAPIVersion"
        value = "v3"
      },
      {
        name  = "gateway.tls.enabled"
        value = "true"
      },
      {
        name  = "gateway.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
        value = "nlb"
      },
      {
        name  = "ingress-controller.config.apisix.adminKey"
        value = random_password.apisix_admin_key.result
      },
      {
        name  = "admin.credentials.admin"
        value = random_password.apisix_admin_key.result
      },
      {
        name  = "admin.credentials.viewer"
        value = random_password.apisix_viewer_key.result
      },
    ],
    var.set
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
  values = var.values
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
