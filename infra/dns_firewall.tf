resource "aws_route53_resolver_firewall_domain_list" "allow_domain_list_dataexfiltration" {
  name    = "allow-list-${local.project}"
  domains = ["pagopa.it.", "*.pagopa.it.", "io.pagopa.it.", "amazonaws.com.", "*.amazonaws.com.", "*.compute.internal."]
}

resource "aws_route53_resolver_firewall_domain_list" "block_domain_list_dataexfiltration" {
  name    = "block-list-${local.project}"
  domains = ["*."]
}

resource "aws_route53_resolver_firewall_rule_group" "rule_group_dataexfiltration" {
  name = "rule-group-${local.project}"
}

resource "aws_route53_resolver_firewall_rule_group_association" "vpc_rule_group_dataexfiltration" {
  name                   = "vpc-rule-${local.project}"
  firewall_rule_group_id = aws_route53_resolver_firewall_rule_group.rule_group_dataexfiltration.id
  priority               = 102
  vpc_id                 = module.vpc_dataexfiltration.vpc_id
}

resource "aws_route53_resolver_firewall_rule" "dns_fw_allow_dataexfiltration" {
  name                    = "dns-fw-${local.project}"
  action                  = "ALLOW"
  firewall_domain_list_id = aws_route53_resolver_firewall_domain_list.allow_domain_list_dataexfiltration.id
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.rule_group_dataexfiltration.id
  priority                = 1
}

resource "aws_route53_resolver_firewall_rule" "dns_fw_block_dataexfiltration" {
  name                    = "dns-fw-${local.project}"
  action                  = "BLOCK"
  block_response          = "NODATA"
  firewall_domain_list_id = aws_route53_resolver_firewall_domain_list.block_domain_list_dataexfiltration.id
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.rule_group_dataexfiltration.id
  priority                = 100
}