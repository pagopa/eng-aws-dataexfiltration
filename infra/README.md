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
| <a name="module_ec2_instance_dataexfiltration_two"></a> [ec2\_instance\_dataexfiltration\_two](#module\_ec2\_instance\_dataexfiltration\_two) | terraform-aws-modules/ec2-instance/aws | 5.7.0 |
| <a name="module_security_group_dataexfiltration_one"></a> [security\_group\_dataexfiltration\_one](#module\_security\_group\_dataexfiltration\_one) | terraform-aws-modules/security-group/aws | ~> 5.0 |
| <a name="module_security_group_dataexfiltration_two"></a> [security\_group\_dataexfiltration\_two](#module\_security\_group\_dataexfiltration\_two) | terraform-aws-modules/security-group/aws | ~> 5.0 |
| <a name="module_vpc_dataexfiltration"></a> [vpc\_dataexfiltration](#module\_vpc\_dataexfiltration) | terraform-aws-modules/vpc/aws | 5.1.2 |
| <a name="module_vpc_endpoints_dataexfiltration"></a> [vpc\_endpoints\_dataexfiltration](#module\_vpc\_endpoints\_dataexfiltration) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | ~> 5.0 |
| <a name="module_vpc_endpoints_s3"></a> [vpc\_endpoints\_s3](#module\_vpc\_endpoints\_s3) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | 5.13.0 |

## Resources

| Name | Type |
|------|------|
| [random_id.unique](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_iam_policy_document.dynamodb_endpoint_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | `"eu-south-1"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Resorce prefix | `string` | `"dex"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Data Exfiltarion Solution | `map(string)` | <pre>{<br/>  "CreatedBy": "Terraform"<br/>}</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
