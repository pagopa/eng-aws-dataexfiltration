module "network_firewall_dataexfiltration" {
  source  = "terraform-aws-modules/network-firewall/aws"
  version = "1.0.1"

  # Firewall
  name        = "${local.project}-firewall"
  description = "Network firewall"

  delete_protection                 = false
  firewall_policy_change_protection = false
  subnet_change_protection          = false

  vpc_id = aws_vpc.main.id
  subnet_mapping = {
    for i in range(0, length(aws_subnet.firewall)) :
    "subnet-fw-${i}" => {
      subnet_id       = element(aws_subnet.firewall[*].id, i)
      ip_address_type = "IPV4"
    }
  }

  # Policy
  create_policy = false
  # change here to switch policy if you need to recreate dataexfiltration policy
  firewall_policy_arn = aws_networkfirewall_firewall_policy.dataexfiltration.arn
  # firewall_policy_arn = aws_networkfirewall_firewall_policy.switch.arn
}

locals {
  firewall_endpoint_ids = [for endpoint in module.network_firewall_dataexfiltration.status[0].sync_states[*].attachment[*].endpoint_id : endpoint[0]]
}

resource "aws_cloudwatch_log_group" "network_firewall_log_group" {
  name = "/aws/${local.project}-network-firewall"
}

# issue https://github.com/hashicorp/terraform-provider-aws/issues/38917
resource "aws_networkfirewall_logging_configuration" "configuration" {
  firewall_arn = module.network_firewall_dataexfiltration.arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.network_firewall_log_group.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
    #    log_destination_config {
    #      log_destination = {
    #        logGroup = aws_cloudwatch_log_group.network_firewall_log_group.name
    #      }
    #      log_destination_type = "CloudWatchLogs"
    #      log_type             = "FLOW"
    #    }
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.network_firewall_log_group.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "TLS"
    }
  }
}

# used if you need to destroy existing policy
resource "aws_networkfirewall_firewall_policy" "switch" {
  name = "${local.project}-policy-switch"

  firewall_policy {
    stateless_default_actions          = ["aws:pass"]
    stateless_fragment_default_actions = ["aws:pass"]
    stateful_engine_options {
      rule_order = "STRICT_ORDER"
    }
  }
}

resource "aws_networkfirewall_firewall_policy" "dataexfiltration" {
  name = "${local.project}-policy-dataexfiltration"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    stateful_engine_options {
      rule_order = "STRICT_ORDER"
    }
    # stateful_default_actions = ["aws:drop_strict", "aws:alert_strict"]
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.stateful_dataexfiltration.arn
      priority     = 1
    }
    tls_inspection_configuration_arn = aws_networkfirewall_tls_inspection_configuration.tls_inspection.arn
  }
}

resource "aws_networkfirewall_rule_group" "stateful_dataexfiltration" {
  name        = "${local.project}-rulegroup-stateful-dataexfiltration"
  description = "Stateful Inspection for denying access to a domain"
  type        = "STATEFUL"
  capacity    = 100

  rule_group {
    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }
    rules_source {
      rules_string = file("${path.module}/suricata.txt")
    }
  }
}
