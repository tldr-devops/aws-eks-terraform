data "aws_region" "current" {}

locals {
  root_password = coalesce(var.root_password, random_password.uptrace_root_password.result)

  # https://github.com/uptrace/helm-charts/blob/master/charts/uptrace/values.yaml
  # https://uptrace.dev/get/config.html
  values = [
    <<-EOT
      clickhouse:
        enabled: false
      postgresql:
        enabled: false
      otelcol:
        enabled: false
      ingress:
        enabled: false

      uptrace:
        config:
          ch:
            addr: clickhouse:9000
            user: default
            password: "${random_password.clickhouse_password.result}"
            database: uptrace

          # PostgreSQL db that is used to store metadata such us metric names, dashboards, alerts, etc
          pg:
            addr: postgresql:5432
            user: uptrace
            password: "${random_password.postgresql_password.result}"
            database: uptrace

          ## A list of pre-configured projects. Each project is fully isolated.
          projects:
            # Conventionally, the first project is used to monitor Uptrace itself.
            - id: 1
              name: Uptrace
              # Token grants write access to the project. Keep a secret.
              token: "${random_password.uptrace_project_tokens[0].result}"
              pinned_attrs:
                - service_name
                - host_name
                - deployment_environment
              # Group spans by deployment.environment attribute.
              group_by_env: false
              # Group funcs spans by service.name attribute.
              group_funcs_by_service: false
              # Enable prom_compat if you want to use the project as a Prometheus datasource in Grafana.
              prom_compat: true

            # Other projects can be used to monitor your applications.
            # To monitor micro-services or multiple related services, use a single project.
            - id: 2
              name: Monitoring
              token: "${random_password.uptrace_project_tokens[1].result}"
              pinned_attrs:
                - service_name
                - host_name
                - deployment_environment
              prom_compat: true

          auth:
            users:
              - name: Admin
                email: "${var.root_email}"
                password: "${local.root_password}"
                notify_by_email: true

          ch_schema:
            # Whether to use Replicated* engines.
            replicated: false

            # Cluster name for Distributed tables and ON CLUSTER clause.
            #cluster: uptrace1

            spans:
              ttl_delete: 90 DAY
              storage_policy: 's3_spans'

            metrics:
              ttl_delete: 90 DAY
              storage_policy: 's3_metrics'

          listen:
            # OTLP/gRPC API.
            grpc:
              addr: ':14317'

            # OTLP/HTTP API and Uptrace API with Vue UI.
            http:
              addr: ':14318'

            # tls:
            #   cert_file: config/tls/uptrace.crt
            #   key_file: config/tls/uptrace.key

          site:
            # Overrides public URL for Vue-powered UI.
            #addr: 'https://uptrace.mydomain.com'

          spans:
            # The size of the Go chan used to buffer incoming spans.
            # If the buffer is full, Uptrace starts to drop spans.
            buffer_size: 100000

            # The number of spans to insert in a single query.
            #batch_size: 10000

          metrics:
            # List of attributes to drop for being noisy.
            drop_attrs:
              - telemetry_sdk_language
              - telemetry_sdk_name
              - telemetry_sdk_version

            # The size of the Go chan used to buffer incoming measures.
            # If the buffer is full, Uptrace starts to drop measures.
            buffer_size: 100000

            # The number of measures to insert in a single query.
            #batch_size: 10000

            # The size of the buffer for converting cumulative metrics to delta.
            #cum_to_delta_size: 100000

          ## SMTP settings to send emails.
          ## https://uptrace.dev/get/alerting.html
          smtp_mailer:
            enabled: false
            host: localhost
            port: 1025
            username: mailhog
            password: mailhog
            from: 'uptrace@localhost'

          # Secret key that is used to sign JWT tokens etc.
          secret_key: "${random_password.uptrace_secret_key.result}"
    EOT
  ]
  set = []

  service_account = "uptrace-clickhouse"

  # https://github.com/bitnami/charts/blob/main/bitnami/clickhouse/values.yaml
  clickhouse_values  = [
    <<-EOT
      shards: 1
      replicaCount: 1
      auth:
        username: default
        existingSecret: "uptrace-clickhouse-password"
        existingSecretKey: "password"
      persistence:
        size: 5Gi
      automountServiceAccountToken: true
      serviceAccount:
        create: true
        name: ${local.service_account}
        annotations:
          eks.amazonaws.com/role-arn: ${module.role.iam_role_arn}
        automountServiceAccountToken: true
      metrics:
        enabled: true
      zookeeper:
        enabled: false
      extraOverrides: |
        <clickhouse>
          <storage_configuration>
              <disks>
                  <s3_default>
                      <type>s3</type>
                      <endpoint>https://${aws_s3_bucket.uptrace.bucket_regional_domain_name}/uptrace/default/</endpoint>
                      <use_environment_credentials>true</use_environment_credentials>

                      <metadata_path>/bitnami/clickhouse/data/disks/s3_default/</metadata_path>
                      <cache_enabled>true</cache_enabled>
                      <data_cache_enabled>true</data_cache_enabled>
                      <enable_filesystem_cache>true</enable_filesystem_cache>
                      <cache_on_write_operations>true</cache_on_write_operations>
                      <max_cache_size>1Gi</max_cache_size>
                      <cache_path>/bitnami/clickhouse/data/disks/s3_default/cache/</cache_path>
                  </s3_default>
                  <s3_metrics>
                      <type>s3</type>
                      <endpoint>https://${aws_s3_bucket.uptrace.bucket_regional_domain_name}/uptrace/metrics/</endpoint>
                      <use_environment_credentials>true</use_environment_credentials>

                      <metadata_path>/bitnami/clickhouse/data/disks/s3_metrics/</metadata_path>
                      <cache_enabled>true</cache_enabled>
                      <data_cache_enabled>true</data_cache_enabled>
                      <enable_filesystem_cache>true</enable_filesystem_cache>
                      <cache_on_write_operations>true</cache_on_write_operations>
                      <max_cache_size>1Gi</max_cache_size>
                      <cache_path>/bitnami/clickhouse/data/disks/s3_metrics/cache/</cache_path>
                  </s3_metrics>
                  <s3_spans>
                      <type>s3</type>
                      <endpoint>https://${aws_s3_bucket.uptrace.bucket_regional_domain_name}/uptrace/spans/</endpoint>
                      <use_environment_credentials>true</use_environment_credentials>

                      <metadata_path>/bitnami/clickhouse/data/disks/s3_spans/</metadata_path>
                      <cache_enabled>true</cache_enabled>
                      <data_cache_enabled>true</data_cache_enabled>
                      <enable_filesystem_cache>true</enable_filesystem_cache>
                      <cache_on_write_operations>true</cache_on_write_operations>
                      <max_cache_size>1Gi</max_cache_size>
                      <cache_path>/bitnami/clickhouse/data/disks/s3_spans/cache/</cache_path>
                  </s3_spans>
              </disks>
              <policies>
                  <default>
                      <volumes>
                          <volume_s3_default>
                              <disk>s3_default</disk>
                          </volume_s3_default>
                      </volumes>
                  </default>
                  <s3_metrics>
                      <volumes>
                          <volume_s3_metrics>
                              <disk>s3_metrics</disk>
                          </volume_s3_metrics>
                      </volumes>
                  </s3_metrics>
                  <s3_spans>
                      <volumes>
                          <volume_s3_spans>
                              <disk>s3_spans</disk>
                          </volume_s3_spans>
                      </volumes>
                  </s3_spans>
                  <duo>
                      <!-- items with equal priorities are ordered by their position in config -->
                      <volumes>
                          <hot>
                              <disk>default</disk>
                          </hot>
                          <cold>
                              <disk>s3_default</disk>
                              <prefer_not_to_merge>true</prefer_not_to_merge>
                          </cold>
                      </volumes>
                      <!-- move data to s3 when disk usage will be more than 90% -->
                      <move_factor>0.1</move_factor>
                  </duo>
              </policies>
          </storage_configuration>
        </clickhouse>
    EOT
  ]

  # https://github.com/bitnami/charts/blob/main/bitnami/postgresql/values.yaml
  postgresql_values  = [
    <<-EOT
      auth:
        ## @param auth.enablePostgresUser Assign a password to the "postgres" admin user. Otherwise, remote access will be blocked for this user
        enablePostgresUser: true
        ## @param auth.postgresPassword Password for the "postgres" admin user. Ignored if `auth.existingSecret` is provided
        # postgresPassword: "${random_password.postgresql_password.result}"
        ## @param auth.username Name for a custom user to create
        username: "uptrace"
        ## @param auth.password Password for the custom user to create. Ignored if `auth.existingSecret` is provided
        # password: "${random_password.postgresql_password.result}"
        ## @param auth.database Name for a custom database to create
        database: "uptrace"
        ## @param auth.existingSecret Name of existing secret to use for PostgreSQL credentials
        existingSecret: "uptrace-postgresql-password"
        secretKeys:
          adminPasswordKey: "password"
          userPasswordKey: "password"
      architecture: standalone
      audit:
        logHostname: false
        logConnections: false
        logDisconnections: false
        pgAuditLog: ""
        pgAuditLogCatalog: "off"
        clientMinMessages: error
        logLinePrefix: ""
        logTimezone: ""
      postgresqlDataDir: /bitnami/postgresql/data
      persistence:
        enabled: true
        mountPath: /bitnami/postgresql
        size: 1Gi
      readReplicas:
        replicaCount: 0
    EOT
  ]
}

resource "random_password" "uptrace_root_password" {
  length           = 32
  special          = false
}

resource "random_password" "uptrace_project_tokens" {
  count = 2
  length           = 32
  special          = false
}

resource "random_password" "uptrace_secret_key" {
  length           = 32
  special          = false
}

resource "random_password" "clickhouse_password" {
  length           = 32
  special          = false
}

resource "random_password" "postgresql_password" {
  length           = 32
  special          = false
}

module "kubernetes_manifests" {
  source = "../kubernetes-manifests"

  create        = var.create
  name          = "uptrace-${var.namespace}-manifests"
  namespace     = var.namespace
  tags          = var.tags

  values = [
    <<-EOT
    resources:
      - kind: Secret
        apiVersion: v1
        metadata:
          name: "uptrace-clickhouse-password"
          namespace: "${var.namespace}"
        stringData:
          password: "${random_password.clickhouse_password.result}"
        type: Opaque
      - kind: Secret
        apiVersion: v1
        metadata:
          name: "uptrace-postgresql-password"
          namespace: "${var.namespace}"
        stringData:
          password: "${random_password.postgresql_password.result}"
        type: Opaque
    EOT
  ]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "uptrace" {
  bucket_prefix = "uptrace-"

  tags = {
    Name        = "uptrace"
    Terraform   = "uptrace"
    Environment = "management"
  }

  # change it for deleting bucket with all content
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "uptrace" {
  bucket = aws_s3_bucket.uptrace.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "uptrace" {
  bucket = aws_s3_bucket.uptrace.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "uptrace" {
  bucket                  = aws_s3_bucket.uptrace.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_policy" "uptrace" {
  name        = aws_s3_bucket.uptrace.id
  path        = "/"
  description = "Policy for ${aws_s3_bucket.uptrace.id} read/write specific S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:*"
        ],
        Resource = [
          "${aws_s3_bucket.uptrace.arn}/*",
          "${aws_s3_bucket.uptrace.arn}"
        ]
      },
    ]
  })
}

module "role" {
  source = "aws-ia/eks-blueprints-addon/aws"
  version = "~> 1.1"

  # Disable helm release
  create_release = false

 # IAM role for service account (IRSA)
  create_role = true
  create_policy = false
  role_name   = "${aws_s3_bucket.uptrace.id}"
  role_policies = merge(
    {
      uptrace = aws_iam_policy.uptrace.arn
    },
    var.role_policies
  )

  oidc_providers = merge(
    {
      uptrace = {
        provider_arn    = var.oidc_provider_arn
        namespace       = var.namespace
        service_account = local.service_account
      }
    },
    var.oidc_providers
  )

  create = var.create
  tags = var.tags
}

module "clickhouse" {
  source = "aws-ia/eks-blueprints-addon/aws"
  version = "~> 1.1"

  depends_on = [
    module.role
  ]

  set = var.clickhouse_set

  values = concat(
    local.clickhouse_values,
    var.clickhouse_values
  )

  create = var.create
  tags = var.tags
  create_release = var.clickhouse_create_release
  name = var.clickhouse_name
  description = var.clickhouse_description
  namespace = var.namespace
  create_namespace = var.clickhouse_create_namespace
  chart = var.clickhouse_chart
  chart_version = var.clickhouse_chart_version
  repository = var.clickhouse_repository
  timeout = var.clickhouse_timeout
  repository_key_file = var.clickhouse_repository_key_file
  repository_cert_file = var.clickhouse_repository_cert_file
  repository_ca_file = var.clickhouse_repository_ca_file
  repository_username = var.clickhouse_repository_username
  repository_password = var.clickhouse_repository_password
  devel = var.clickhouse_devel
  verify = var.clickhouse_verify
  keyring = var.clickhouse_keyring
  disable_webhooks = var.clickhouse_disable_webhooks
  reuse_values = var.clickhouse_reuse_values
  reset_values = var.clickhouse_reset_values
  force_update = var.clickhouse_force_update
  recreate_pods = var.clickhouse_recreate_pods
  cleanup_on_fail = var.clickhouse_cleanup_on_fail
  max_history = var.clickhouse_max_history
  atomic = var.clickhouse_atomic
  skip_crds = var.clickhouse_skip_crds
  render_subchart_notes = var.clickhouse_render_subchart_notes
  disable_openapi_validation = var.clickhouse_disable_openapi_validation
  wait = var.clickhouse_wait
  wait_for_jobs = var.clickhouse_wait_for_jobs
  dependency_update = var.clickhouse_dependency_update
  replace = var.clickhouse_replace
  lint = var.clickhouse_lint
  postrender = var.clickhouse_postrender
  set_sensitive = var.clickhouse_set_sensitive
  set_irsa_names = var.clickhouse_set_irsa_names
}

module "postgresql" {
  source = "aws-ia/eks-blueprints-addon/aws"
  version = "~> 1.1"

  set = var.postgresql_set

  values = concat(
    local.postgresql_values,
    var.postgresql_values
  )

  create = var.create
  tags = var.tags
  create_release = var.postgresql_create_release
  name = var.postgresql_name
  description = var.postgresql_description
  namespace = var.namespace
  create_namespace = var.postgresql_create_namespace
  chart = var.postgresql_chart
  chart_version = var.postgresql_chart_version
  repository = var.postgresql_repository
  timeout = var.postgresql_timeout
  repository_key_file = var.postgresql_repository_key_file
  repository_cert_file = var.postgresql_repository_cert_file
  repository_ca_file = var.postgresql_repository_ca_file
  repository_username = var.postgresql_repository_username
  repository_password = var.postgresql_repository_password
  devel = var.postgresql_devel
  verify = var.postgresql_verify
  keyring = var.postgresql_keyring
  disable_webhooks = var.postgresql_disable_webhooks
  reuse_values = var.postgresql_reuse_values
  reset_values = var.postgresql_reset_values
  force_update = var.postgresql_force_update
  recreate_pods = var.postgresql_recreate_pods
  cleanup_on_fail = var.postgresql_cleanup_on_fail
  max_history = var.postgresql_max_history
  atomic = var.postgresql_atomic
  skip_crds = var.postgresql_skip_crds
  render_subchart_notes = var.postgresql_render_subchart_notes
  disable_openapi_validation = var.postgresql_disable_openapi_validation
  wait = var.postgresql_wait
  wait_for_jobs = var.postgresql_wait_for_jobs
  dependency_update = var.postgresql_dependency_update
  replace = var.postgresql_replace
  lint = var.postgresql_lint
  postrender = var.postgresql_postrender
  set_sensitive = var.postgresql_set_sensitive
  set_irsa_names = var.postgresql_set_irsa_names
}

module "uptrace" {
  source = "aws-ia/eks-blueprints-addon/aws"
  version = "~> 1.1"

  depends_on = [
    module.clickhouse,
    module.postgresql
  ]

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
  role_path = var.role_path
  role_permissions_boundary_arn = var.role_permissions_boundary_arn
  role_description = var.role_description
  max_session_duration = var.max_session_duration
  assume_role_condition_test = var.assume_role_condition_test
  allow_self_assume_role = var.allow_self_assume_role
}

# https://grafana.github.io/grafana-operator/docs/datasources/
module "grafana_operator_datasource" {
  source = "../kubernetes-manifests"

  create        = var.grafana_operator_integration
  name          = "uptrace-${var.namespace}-datasource"
  namespace     = var.grafana_operator_namespace
  tags          = var.tags

  values = [
    <<-EOT
    resources:
      - kind: Secret
        apiVersion: v1
        metadata:
          name: "uptrace-${var.namespace}-datasource-credentials"
          namespace: "${var.grafana_operator_namespace}"
        stringData:
          token1: "${random_password.uptrace_project_tokens[0].result}"
          header1: "http://${random_password.uptrace_project_tokens[0].result}@${module.uptrace.chart}.${module.uptrace.namespace}.svc:14318/1?grpc=14317"
          token2: "${random_password.uptrace_project_tokens[1].result}"
          header2: "http://${random_password.uptrace_project_tokens[1].result}@${module.uptrace.chart}.${module.uptrace.namespace}.svc:14318/2?grpc=14317"
        type: Opaque
      - apiVersion: grafana.integreatly.org/v1beta1
        kind: GrafanaDatasource
        metadata:
          name: "uptrace-${var.namespace}-uptrace-prometheus-datasource"
        spec:
          valuesFrom:
            - targetPath: "secureJsonData.httpHeaderValue1"
              valueFrom:
                secretKeyRef:
                  name: "uptrace-${var.namespace}-datasource-credentials"
                  key: "header1"
          instanceSelector:
            matchLabels:
              dashboards: "grafana"
          datasource:
            name: "Uptrace-${var.namespace}"
            type: prometheus
            access: proxy
            url: "http://${module.uptrace.chart}.${module.uptrace.namespace}.svc:14318/api/prometheus"
            isDefault: false
            jsonData:
              "httpHeaderName1": "uptrace-dsn"
              "tlsSkipVerify": true
              "timeInterval": "5s"
            secureJsonData:
              "httpHeaderValue1": "$${header1}" # Notice the brakes around
            editable: true
      - apiVersion: grafana.integreatly.org/v1beta1
        kind: GrafanaDatasource
        metadata:
          name: "uptrace-${var.namespace}-uptrace-tempo-datasource"
        spec:
          valuesFrom:
            - targetPath: "secureJsonData.httpHeaderValue1"
              valueFrom:
                secretKeyRef:
                  name: "uptrace-${var.namespace}-datasource-credentials"
                  key: "header1"
          instanceSelector:
            matchLabels:
              dashboards: "grafana"
          datasource:
            name: "Uptrace-Tempo-${var.namespace}"
            type: tempo
            access: proxy
            url: "http://${module.uptrace.chart}.${module.uptrace.namespace}.svc:14318/api/tempo"
            isDefault: false
            jsonData:
              "httpHeaderName1": "uptrace-dsn"
              "tlsSkipVerify": true
              "timeInterval": "5s"
            secureJsonData:
              "httpHeaderValue1": "$${header1}" # Notice the brakes around
            editable: true
      - apiVersion: grafana.integreatly.org/v1beta1
        kind: GrafanaDatasource
        metadata:
          name: "uptrace-${var.namespace}-monitoring-prometheus-datasource"
        spec:
          valuesFrom:
            - targetPath: "secureJsonData.httpHeaderValue1"
              valueFrom:
                secretKeyRef:
                  name: "uptrace-${var.namespace}-datasource-credentials"
                  key: "header2"
          instanceSelector:
            matchLabels:
              dashboards: "grafana"
          datasource:
            name: "Uptrace-Monitoring-${var.namespace}"
            type: prometheus
            access: proxy
            url: "http://${module.uptrace.chart}.${module.uptrace.namespace}.svc:14318/api/prometheus"
            isDefault: false
            jsonData:
              "httpHeaderName1": "uptrace-dsn"
              "tlsSkipVerify": true
              "timeInterval": "5s"
            secureJsonData:
              "httpHeaderValue1": "$${header2}" # Notice the brakes around
            editable: true
      - apiVersion: grafana.integreatly.org/v1beta1
        kind: GrafanaDatasource
        metadata:
          name: "uptrace-${var.namespace}-monitoring-tempo-datasource"
        spec:
          valuesFrom:
            - targetPath: "secureJsonData.httpHeaderValue1"
              valueFrom:
                secretKeyRef:
                  name: "uptrace-${var.namespace}-datasource-credentials"
                  key: "header2"
          instanceSelector:
            matchLabels:
              dashboards: "grafana"
          datasource:
            name: "Uptrace-Monitoring-Tempo-${var.namespace}"
            type: tempo
            access: proxy
            url: "http://${module.uptrace.chart}.${module.uptrace.namespace}.svc:14318/api/tempo"
            isDefault: false
            jsonData:
              "httpHeaderName1": "uptrace-dsn"
              "tlsSkipVerify": true
              "timeInterval": "5s"
            secureJsonData:
              "httpHeaderValue1": "$${header2}" # Notice the brakes around
            editable: true
    EOT
  ]
}
