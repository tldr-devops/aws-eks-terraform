module "kubernetes_manifests" {
  source = "aws-ia/eks-blueprints-addon/aws"
  version = "~> 1.1"

  chart = "${path.module}/chart"

  tags = var.tags
  create_release = var.create_release
  name = var.name
  description = var.description
  namespace = var.namespace
  create_namespace = var.create_namespace
  values = var.values
  timeout = var.timeout
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
  replace = var.replace
  lint = var.lint
  postrender = var.postrender
  set = var.set
  set_sensitive = var.set_sensitive
}
