# infra

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.9.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.65.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2_instance_dataexfiltration_one"></a> [ec2\_instance\_dataexfiltration\_one](#module\_ec2\_instance\_dataexfiltration\_one) | terraform-aws-modules/ec2-instance/aws | 5.7.0 |
| <a name="module_ec2_instance_dataexfiltration_sni_listener"></a> [ec2\_instance\_dataexfiltration\_sni\_listener](#module\_ec2\_instance\_dataexfiltration\_sni\_listener) | terraform-aws-modules/ec2-instance/aws | 5.7.0 |
| <a name="module_network_firewall_dataexfiltration"></a> [network\_firewall\_dataexfiltration](#module\_network\_firewall\_dataexfiltration) | terraform-aws-modules/network-firewall/aws | 1.0.1 |
| <a name="module_s3_tls_inspection"></a> [s3\_tls\_inspection](#module\_s3\_tls\_inspection) | terraform-aws-modules/s3-bucket/aws | 4.1.1 |
| <a name="module_security_group_dataexfiltration_lambda_proxy"></a> [security\_group\_dataexfiltration\_lambda\_proxy](#module\_security\_group\_dataexfiltration\_lambda\_proxy) | terraform-aws-modules/security-group/aws | n/a |
| <a name="module_security_group_dataexfiltration_one"></a> [security\_group\_dataexfiltration\_one](#module\_security\_group\_dataexfiltration\_one) | terraform-aws-modules/security-group/aws | ~> 5.0 |
| <a name="module_security_group_dataexfiltration_sni_listener"></a> [security\_group\_dataexfiltration\_sni\_listener](#module\_security\_group\_dataexfiltration\_sni\_listener) | terraform-aws-modules/security-group/aws | n/a |
| <a name="module_vpc_dataexfiltration"></a> [vpc\_dataexfiltration](#module\_vpc\_dataexfiltration) | terraform-aws-modules/vpc/aws | 5.13.0 |
| <a name="module_vpc_endpoints_aws"></a> [vpc\_endpoints\_aws](#module\_vpc\_endpoints\_aws) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | 5.13.0 |
| <a name="module_vpc_endpoints_dataexfiltration"></a> [vpc\_endpoints\_dataexfiltration](#module\_vpc\_endpoints\_dataexfiltration) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | 5.13.0 |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.tls_inspection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_cloudwatch_log_group.network_firewall_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.lambda_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.lambda_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_lambda_function.lambda_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function_url.lambda_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_url) | resource |
| [aws_lambda_layer_version.tls_inspection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_layer_version) | resource |
| [aws_networkfirewall_firewall_policy.dataexfiltration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy) | resource |
| [aws_networkfirewall_firewall_policy.switch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy) | resource |
| [aws_networkfirewall_logging_configuration.configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_logging_configuration) | resource |
| [aws_networkfirewall_rule_group.stateful_dataexfiltration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_tls_inspection_configuration.tls_inspection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_tls_inspection_configuration) | resource |
| [aws_route.firewall_tointernet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.nat_gateway_to_firewall](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route53_resolver_firewall_domain_list.allow_domain_list_dataexfiltration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_domain_list) | resource |
| [aws_route53_resolver_firewall_domain_list.block_domain_list_dataexfiltration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_domain_list) | resource |
| [aws_route53_resolver_firewall_rule.dns_fw_allow_dataexfiltration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_rule) | resource |
| [aws_route53_resolver_firewall_rule.dns_fw_block_dataexfiltration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_rule) | resource |
| [aws_route53_resolver_firewall_rule_group.rule_group_dataexfiltration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_rule_group) | resource |
| [aws_route53_resolver_firewall_rule_group_association.vpc_rule_group_dataexfiltration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_rule_group_association) | resource |
| [aws_route_table.route_table_igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.route_add_igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_s3_object.tls_inspection_ca_certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [random_id.unique](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [tls_private_key.tls_inspection](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.tls_inspection](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |
| [archive_file.lambda_proxy](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.tls_inspection_ca_certificate](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_ami.aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_iam_policy_document.dynamodb_endpoint_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_subnets.firewall](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_subnets.nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | `"eu-south-1"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Resorce prefix | `string` | `"dex"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Data Exfiltarion Solution | `map(string)` | <pre>{<br/>  "CreatedBy": "Terraform"<br/>}</pre> | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | vpc cidr block | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_lambda_proxy_function_url"></a> [aws\_lambda\_proxy\_function\_url](#output\_aws\_lambda\_proxy\_function\_url) | n/a |
| <a name="output_ec2_sni_listener_public_ip"></a> [ec2\_sni\_listener\_public\_ip](#output\_ec2\_sni\_listener\_public\_ip) | n/a |
| <a name="output_project"></a> [project](#output\_project) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
