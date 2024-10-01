data "aws_caller_identity" "current" {}

locals {
  region     = "eu-south-1"
  account_id = data.aws_caller_identity.current.account_id
  vpc_cidr   = "10.0.0.0/16"
  num_azs    = 3
  azs        = slice(data.aws_availability_zones.available.names, 0, local.num_azs)
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
    for i in range(0, local.num_azs) :
    "subnet-private-${i}" => {
      subnet_id       = element(module.vpc_dataexfiltration.private_subnets, i)
      ip_address_type = "IPV4"
    }
  }

  # Policy
  policy_name        = "${local.project}-firewall-policy"
  policy_description = "Network firewall policy"

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
        target_types         = ["HTTP_HOST"]
        targets              = [".pagopa.it"]
      }
    }
  }

  # Resource Policy
  create_resource_policy     = true
  attach_resource_policy     = true
  resource_policy_principals = ["arn:aws:iam::${local.account_id}:root"]
}