data "aws_region" "current" {}

locals {
  root_user = var.root_email
  root_password = coalesce(var.root_password, random_password.qryn_root_password.result)

  # https://github.com/metrico/qryn-helm/blob/main/values.yaml
  values = [
    <<-EOT
      livenessProbe:
        enabled: false # failed with 401
        endpoint: "/metrics"
      serviceMonitor:
        enabled: true
      autoscaling:
        enabled: true
      resources:
        limits:
          cpu: 1000m
          memory: 1024Mi
      env:
        CLICKHOUSE_SERVER: "${var.clickhouse_name}"
        CLICKHOUSE_PORT: "8123"
        CLICKHOUSE_DB: "qryn"
        CLICKHOUSE_AUTH: "default:${random_password.clickhouse_password.result}"
        LABELS_DAYS: "30"
        SAMPLES_DAYS: "30"
        QRYN_LOGIN: "${local.root_user}"
        QRYN_PASSWORD: "${local.root_password}"
        DEBUG: "false"
        LOG_LEVEL: "info"
        STORAGE_POLICY: "policy_s3_only"
        # HASH: "xxhash64"
        # ALERTMAN_URL: "false"
    EOT
  ]
  set = []

  service_account = "qryn-clickhouse"

  # https://github.com/bitnami/charts/blob/main/bitnami/clickhouse/values.yaml
  # https://uptrace.dev/get/config.html#s3-storage
  # https://altinity.com/blog/clickhouse-mergetree-on-s3-administrative-best-practices
  clickhouse_values  = [
    <<-EOT
      shards: 1
      replicaCount: 1
      auth:
        username: default
        existingSecret: "qryn-clickhouse-password"
        existingSecretKey: "password"
      persistence:
        size: 10Gi
      automountServiceAccountToken: true
      serviceAccount:
        create: true
        name: ${local.service_account}
        annotations:
          eks.amazonaws.com/role-arn: ${module.role.iam_role_arn}
        automountServiceAccountToken: true
      resourcesPreset: "none"
      metrics:
        enabled: true
      zookeeper:
        enabled: false
      extraOverrides: |
        <clickhouse>
          <storage_configuration>
              <disks>
                  <disk_s3>
                      <type>s3</type>
                      <endpoint>https://${aws_s3_bucket.qryn.bucket_regional_domain_name}/qryn/</endpoint>
                      <use_environment_credentials>true</use_environment_credentials>
                      <metadata_path>/bitnami/clickhouse/data/disks/s3_default/</metadata_path>
                      <cache_enabled>true</cache_enabled>
                      <data_cache_enabled>true</data_cache_enabled>
                      <enable_filesystem_cache>true</enable_filesystem_cache>
                      <cache_on_write_operations>false</cache_on_write_operations>
                      <max_cache_size>2Gi</max_cache_size>
                      <cache_path>/bitnami/clickhouse/data/disks/s3_default/cache/</cache_path>
                  </disk_s3>
              </disks>
              <policies>
                  <policy_s3_only>
                      <!-- items with equal priorities are ordered by their position in config -->
                      <volumes>
                          <hot>
                              <disk>default</disk>
                          </hot>
                          <cold>
                              <disk>disk_s3</disk>
                              <prefer_not_to_merge>true</prefer_not_to_merge>
                              <perform_ttl_move_on_insert>0</perform_ttl_move_on_insert>
                          </cold>
                      </volumes>
                      <!-- move data to s3 when disk usage will be more than 90% -->
                      <move_factor>0.2</move_factor>
                  </policy_s3_only>
              </policies>
          </storage_configuration>
        </clickhouse>
    EOT
  ]
}

resource "random_password" "qryn_root_password" {
  length           = 32
  special          = false
}

resource "random_password" "clickhouse_password" {
  length           = 32
  special          = false
}

module "kubernetes_manifests" {
  source = "../kubernetes-manifests"

  create        = var.create
  name          = "qryn-${var.namespace}-manifests"
  namespace     = var.namespace
  tags          = var.tags

  values = [
    <<-EOT
    resources:
      - kind: Secret
        apiVersion: v1
        metadata:
          name: "qryn-clickhouse-password"
          namespace: "${var.namespace}"
        stringData:
          password: "${random_password.clickhouse_password.result}"
        type: Opaque
    EOT
  ]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "qryn" {
  bucket_prefix = "qryn-"

  tags = {
    Name        = "qryn"
    Terraform   = "qryn"
    Environment = "management"
  }

  # change it for deleting bucket with all content
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "qryn" {
  bucket = aws_s3_bucket.qryn.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "qryn" {
  bucket = aws_s3_bucket.qryn.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "qryn" {
  bucket                  = aws_s3_bucket.qryn.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_policy" "qryn" {
  name        = aws_s3_bucket.qryn.id
  path        = "/"
  description = "Policy for ${aws_s3_bucket.qryn.id} read/write specific S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:*"
        ],
        Resource = [
          "${aws_s3_bucket.qryn.arn}/*",
          "${aws_s3_bucket.qryn.arn}"
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
  role_name   = "${aws_s3_bucket.qryn.id}"
  role_policies = merge(
    {
      qryn = aws_iam_policy.qryn.arn
    },
    var.role_policies
  )

  oidc_providers = merge(
    {
      qryn = {
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

module "qryn" {
  source = "aws-ia/eks-blueprints-addon/aws"
  version = "~> 1.1"

  depends_on = [
    module.clickhouse
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
  count = var.grafana_operator_integration == true ? 1 : 0

  name          = "qryn-${var.namespace}-datasource"
  namespace     = var.grafana_operator_namespace
  tags          = var.tags

  values = [
    <<-EOT
    resources:
      - kind: Secret
        apiVersion: v1
        metadata:
          name: "qryn-${var.namespace}-datasource-credentials"
          namespace: "${var.grafana_operator_namespace}"
        stringData:
          username: "${local.root_user}"
          password: "${local.root_password}"
        type: Opaque
      - apiVersion: grafana.integreatly.org/v1beta1
        kind: GrafanaDatasource
        metadata:
          name: "qryn-${var.namespace}-datasource"
        spec:
          valuesFrom:
            - targetPath: "user"
              valueFrom:
                secretKeyRef:
                  name: "qryn-${var.namespace}-datasource-credentials"
                  key: "username"
            - targetPath: "secureJsonData.password"
              valueFrom:
                secretKeyRef:
                  name: "qryn-${var.namespace}-datasource-credentials"
                  key: "password"
          instanceSelector:
            matchLabels:
              dashboards: "grafana"
          datasource:
            name: "Qryn-${var.namespace}"
            type: prometheus
            access: proxy
            basicAuth: true
            url: "http://${module.qryn.chart}.${module.qryn.namespace}.svc:3100"
            isDefault: false
            user: "$${username}"
            jsonData:
              "tlsSkipVerify": true
              "timeInterval": "5s"
            secureJsonData:
              "password": "$${password}" # Notice the brakes around
            editable: true
    EOT
  ]
}
