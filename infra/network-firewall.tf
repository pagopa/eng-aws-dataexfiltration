data "aws_subnets" "firewall" {
  filter {
    name = "tag:Name"
    values = [
      "${local.project}-public-fw-1",
      "${local.project}-public-fw-2",
      "${local.project}-public-fw-3",
    ]
  }
}

module "network_firewall_dataexfiltration" {
  source  = "terraform-aws-modules/network-firewall/aws"
  version = "1.0.1"

  # Firewall
  name        = "${local.project}-firewall"
  description = "Network firewall"

  delete_protection                 = false
  firewall_policy_change_protection = false
  subnet_change_protection          = false

  vpc_id = module.vpc_dataexfiltration.vpc_id
  subnet_mapping = {
    for i in range(0, length(data.aws_subnets.firewall.ids)) :
    "subnet-public-fw-${i}" => {
      subnet_id       = element(data.aws_subnets.firewall.ids, i)
      ip_address_type = "IPV4"
    }
  }

  # Policy
  policy_name        = "${local.project}-firewall-policy"
  policy_description = "Network firewall policy"

  policy_stateless_default_actions          = ["aws:forward_to_sfe"]
  policy_stateless_fragment_default_actions = ["aws:forward_to_sfe"]

  policy_stateful_rule_group_reference = {
    one = { resource_arn = module.network_firewall_rule_group_stateful_dataexfiltration.arn }
  }
}

module "network_firewall_rule_group_stateful_dataexfiltration" {
  source  = "terraform-aws-modules/network-firewall/aws//modules/rule-group"
  version = "1.0.1"

  name        = "${local.project}-rule-stateful"
  description = "Stateful Inspection for denying access to a domain"
  type        = "STATEFUL"
  capacity    = 100

  rule_group = {
    rules_source = {
      rules_source_list = {
        generated_rules_type = "ALLOWLIST"
        target_types         = ["HTTP_HOST","TLS_SNI"]
        targets              = [".pagopa.it"]
      }
    }
  }

  # Resource Policy
  create_resource_policy     = true
  attach_resource_policy     = true
  resource_policy_principals = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
}

resource "aws_cloudwatch_log_group" "anfw_alert_log_group" {
  name = "/aws/network-firewall/alert"
}

resource "random_string" "bucket_random_id" {
  length  = 5
  special = false
  upper   = false
}

resource "aws_s3_bucket" "anfw_flow_bucket" {
  bucket        = "network-firewall-flow-bucket-${random_string.bucket_random_id.id}"
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.anfw_flow_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "anfw_flow_bucket_ownership_control" {
  bucket = aws_s3_bucket.anfw_flow_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "anfw_flow_bucket_public_access_block" {
  bucket = aws_s3_bucket.anfw_flow_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_networkfirewall_logging_configuration" "anfw_alert_logging_configuration" {
  firewall_arn = module.network_firewall_dataexfiltration.arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.anfw_alert_log_group.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
    log_destination_config {
      log_destination = {
        bucketName = aws_s3_bucket.anfw_flow_bucket.bucket
      }
      log_destination_type = "S3"
      log_type             = "FLOW"
    }
  }
}