data "aws_region" "current" {}

locals {
  zo_root_user_password = try(var.zo_root_user_password, random_password.apisix_admin_key.result)

  # https://openobserve.ai/docs/environment-variables/
  values = [
    <<-EOT
      auth:
        ZO_ROOT_USER_EMAIL: ${var.zo_root_user_email}
        ZO_ROOT_USER_PASSWORD: ${local.zo_root_user_password}
      serviceAccount:
        create: true
        name: "openobserve"
      config:
        ZO_LOCAL_MODE_STORAGE: "s3"
        ZO_META_STORE: "dynamodb"
        ZO_TELEMETRY: false
        ZO_PROMETHEUS_ENABLED: true
        ZO_S3_REGION_NAME: ${data.aws_region.current.name}
        ZO_S3_BUCKET_NAME: ${aws_s3_bucket.openobserve.id}
        ZO_S3_PROVIDER: "aws"
    EOT
  ]
  set = []
}

resource "random_password" "openobserve_root_password" {
  length           = 32
  special          = true
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "openobserve" {
  bucket_prefix = "openobserve-"

  tags = {
    Name        = "openobserve"
    Terraform   = "openobserve"
    Environment = "management"
  }

  # change it for deleting bucket with all content
  force_destroy = false
}

resource "aws_s3_bucket_versioning" "openobserve" {
  bucket = aws_s3_bucket.openobserve.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "openobserve" {
  bucket = aws_s3_bucket.openobserve.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "openobserve" {
  bucket                  = aws_s3_bucket.openobserve.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "openobserve" {
  name         = aws_s3_bucket.openobserve.id
  billing_mode = "PAY_PER_REQUEST"

}

resource "aws_iam_policy" "openobserve" {
  name        = aws_s3_bucket.openobserve.id
  path        = "/"
  description = "Policy for ${aws_s3_bucket.openobserve.id} to list S3 buckets, and read/write specific S3 bucket and DynamoDB table"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListAllMyBuckets"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "aws_s3_bucket.openobserve.arn/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ],
        Resource = [
          "aws_dynamodb_table.openobserve.arn"
        ]
      }
    ]
  })
}

module "openobserve" {
  source = "aws-ia/eks-blueprints-addon/aws"
  version = "~> 1.1"

 # IAM role for service account (IRSA)
  create_role = true
  create_policy = false
  role_name   = aws_s3_bucket.openobserve.id
  role_policies = merge(
    {
      aws_s3_bucket.openobserve.id = aws_iam_policy.openobserve.arn
    },
    var.role_policies
  )

  oidc_providers = merge(
    {
      openobserve = {
        provider_arn    = var.oidc_provider_arn
        namespace       = var.namespace
        service_account = "openobserve"
      }
    },
    var.oidc_providers
  )

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
  role_path = var.role_path
  role_permissions_boundary_arn = var.role_permissions_boundary_arn
  role_description = var.role_description
  role_policies = var.role_policies
  oidc_providers = var.oidc_providers
  max_session_duration = var.max_session_duration
  assume_role_condition_test = var.assume_role_condition_test
  allow_self_assume_role = var.allow_self_assume_role
}
