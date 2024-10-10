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

  # rule_group = {
  #   rules_source = {
  #     rules_source_list = {
  #       generated_rules_type = "ALLOWLIST"
  #       target_types         = ["HTTP_HOST", "TLS_SNI"]
  #       targets              = [".pagopa.it"]
  #     }
  #   }
  # }

  rules = file("${path.module}/suricata.txt")

  # Resource Policy
  create_resource_policy     = true
  attach_resource_policy     = true
  resource_policy_principals = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
}

resource "aws_cloudwatch_log_group" "network_firewall_log_group" {
  name = "/aws/${local.project}-network-firewall"
}

# issue https://github.com/hashicorp/terraform-provider-aws/issues/38917
# resource "aws_networkfirewall_logging_configuration" "network_firewall_logging_configuration" {
#   firewall_arn = module.network_firewall_dataexfiltration.arn
#   logging_configuration {
#     log_destination_config {
#       log_destination = {
#         logGroup = aws_cloudwatch_log_group.network_firewall_log_group.name
#       }
#       log_destination_type = "CloudWatchLogs"
#       log_type             = "ALERT"
#     }
#     log_destination_config {
#       log_destination = {
#         logGroup = aws_cloudwatch_log_group.network_firewall_log_group.name
#       }
#       log_destination_type = "CloudWatchLogs"
#       log_type             = "FLOW"
#     }
#     log_destination_config {
#       log_destination = {
#         logGroup = aws_cloudwatch_log_group.network_firewall_log_group.name
#       }
#       log_destination_type = "CloudWatchLogs"
#       log_type             = "TLS"
#     }
#   }
# }
