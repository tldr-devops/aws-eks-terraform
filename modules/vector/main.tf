# locals {
#   persistence = var.vector_role == "Aggregator"? true : false
# 
#   # https://github.com/vectordotdev/helm-charts/blob/develop/charts/vector/values.yaml
#   values = [
#     <<-EOT
#     role: "${var.vector_role}"
# 
#     # customConfig -- Override Vector's default configs, if used **all** options need to be specified. This section supports
#     # using helm templates to populate dynamic values. See Vector's [configuration documentation](https://vector.dev/docs/reference/configuration/)
#     # for all options.
#     customConfig:
#       data_dir: /vector-data-dir
#       api:
#         enabled: true
#         address: 127.0.0.1:8686
#         playground: false
# 
#       # https://vector.dev/docs/reference/configuration/sources/
#       %{ if var.vector_sources }
#       ${indent(6, var.vector_sources)}
#       %{ else }
#       %{ if var.vector_role == "Agent" }
#       sources:
#         kubernetes_logs:
#           type: kubernetes_logs
#         host_metrics:
#           filesystem:
#             devices:
#               excludes: [binfmt_misc]
#             filesystems:
#               excludes: [binfmt_misc]
#             mountpoints:
#               excludes: ["*/proc/sys/fs/binfmt_misc"]
#           type: host_metrics
#         internal_metrics:
#           type: internal_metrics
#       %{ else }
#       sources:
#         datadog_agent:
#           address: 0.0.0.0:8282
#           type: datadog_agent
#         fluent:
#           address: 0.0.0.0:24224
#           type: fluent
#         internal_metrics:
#           type: internal_metrics
#         logstash:
#           address: 0.0.0.0:5044
#           type: logstash
#         splunk_hec:
#           address: 0.0.0.0:8080
#           type: splunk_hec
#         statsd:
#           address: 0.0.0.0:8125
#           mode: tcp
#           type: statsd
#         syslog:
#           address: 0.0.0.0:9000
#           mode: tcp
#           type: syslog
#         vector:
#           address: 0.0.0.0:6000
#           type: vector
#           version: "2"
#       %{ endif }
#       %{ endif }
# 
#       # https://vector.dev/docs/reference/configuration/transforms/
#       %{ if var.vector_transforms }
#       ${indent(6, var.vector_transforms)}
#       %{ else }
#       %{ if var.vector_role == "Agent" }
#       transforms: {}
#       %{ else }
#       transforms: {}
#       %{ endif }
#       %{ endif }
# 
#       # https://vector.dev/docs/reference/configuration/sinks/
#       %{ if var.vector_sinks }
#       ${indent(6, var.vector_sinks)}
#       %{ else }
#       %{ if var.vector_role == "Agent" }
#       sinks:
#         prom_exporter:
#           type: prometheus_exporter
#           inputs: [host_metrics, internal_metrics]
#           address: 0.0.0.0:9090
#         stdout:
#           type: console
#           inputs: [kubernetes_logs]
#           encoding:
#             codec: json
#       %{ else }
#       sinks:
#         prom_exporter:
#           type: prometheus_exporter
#           inputs: [internal_metrics]
#           address: 0.0.0.0:9090
#         stdout:
#           type: console
#           inputs: [datadog_agent, fluent, logstash, splunk_hec, statsd, syslog, vector]
#           encoding:
#             codec: json
#       %{ endif }
#       %{ endif }
# 
#     # Configuration for Vector's data persistence.
#     persistence:
#       enabled: "${local.persistence}"
#     EOT
#   ]
# 
# }

module "vector" {
  source = "aws-ia/eks-blueprints-addon/aws"
  version = "~> 1.1"

  set =var.set
  values = var.values

#   values = concat(
#     local.values,
#     var.values
#   )

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
