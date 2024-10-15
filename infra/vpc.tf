module "vpc_dataexfiltration" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name = local.project
  cidr = "10.0.0.0/16"
  azs  = data.aws_availability_zones.available.names
  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
  ]
  private_subnet_names = [
    "${local.project}-private-1",
    "${local.project}-private-2",
    "${local.project}-private-3",
  ]
  public_subnets = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.251.0/24",
    "10.0.252.0/24",
    "10.0.253.0/24",
  ]
  public_subnet_names = [
    "${local.project}-public-natgw-1",
    "${local.project}-public-natgw-2",
    "${local.project}-public-natgw-3",
    "${local.project}-public-fw-1",
    "${local.project}-public-fw-2",
    "${local.project}-public-fw-3",
  ]
  public_dedicated_network_acl        = true
  enable_nat_gateway                  = true
  single_nat_gateway                  = false
  one_nat_gateway_per_az              = true
  enable_dns_hostnames                = true
  enable_dns_support                  = true
  create_multiple_public_route_tables = true
  create_igw                          = false
}

data "aws_subnets" "nat_gateway" {
  filter {
    name = "tag:Name"
    values = [
      "${local.project}-public-natgw-1",
      "${local.project}-public-natgw-2",
      "${local.project}-public-natgw-3",
    ]
  }
}

module "vpc_endpoints_dataexfiltration" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "5.13.0"

  vpc_id = module.vpc_dataexfiltration.vpc_id

  endpoints = { for service in toset(["ssm", "ssmmessages", "ec2messages"]) :
    replace(service, ".", "_") =>
    {
      service             = service
      subnet_ids          = module.vpc_dataexfiltration.private_subnets
      private_dns_enabled = true
    }
  }

  create_security_group      = true
  security_group_name_prefix = "${local.project}-vpc-endpoints"
  security_group_description = "VPC endpoint security group"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from subnets"
      cidr_blocks = module.vpc_dataexfiltration.private_subnets_cidr_blocks
    }
  }
}

module "vpc_endpoints_aws" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "5.13.0"

  vpc_id = module.vpc_dataexfiltration.vpc_id

  create_security_group      = true
  security_group_name_prefix = "${local.project}-vpc-endpoints-aws"
  security_group_description = "VPC endpoint security group"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [module.vpc_dataexfiltration.vpc_cidr_block]
    }
  }

  endpoints = {
    s3 = {
      service             = "s3"
      tags                = { Name = "s3-vpc-endpoint" }
      private_dns_enabled = true
      dns_options = {
        private_dns_only_for_inbound_resolver_endpoint = false
      }
    },
    dynamodb = {
      service         = "dynamodb"
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc_dataexfiltration.private_route_table_ids, module.vpc_dataexfiltration.public_route_table_ids])
      policy          = data.aws_iam_policy_document.dynamodb_endpoint_policy.json
      tags            = { Name = "dynamodb-vpc-endpoint" }
    }
  }
}

data "aws_iam_policy_document" "dynamodb_endpoint_policy" {
  statement {
    effect    = "Deny"
    actions   = ["dynamodb:*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:sourceVpc"

      values = [module.vpc_dataexfiltration.vpc_id]
    }
  }
}

variable "cidr_blocks" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

resource "aws_internet_gateway" "this" {
  vpc_id = module.vpc_dataexfiltration.vpc_id
  tags = {
    Name = "${local.project}-igw"
  }
}

resource "aws_route_table" "route_table_igw" {
  vpc_id = module.vpc_dataexfiltration.vpc_id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  dynamic "route" {
    for_each = zipmap(var.cidr_blocks, local.firewall_endpoint_ids)
    content {
      cidr_block      = route.key
      vpc_endpoint_id = route.value
    }
  }

  tags = {
    Name = "${local.project}-igw-fw"
  }
}

resource "aws_route_table_association" "route_add_igw" {
  gateway_id     = aws_internet_gateway.this.id
  route_table_id = aws_route_table.route_table_igw.id
}

resource "aws_route" "nat_gateway_to_firewall" {
  for_each               = toset(["0", "1", "2"])
  route_table_id         = module.vpc_dataexfiltration.public_route_table_ids[each.key]
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.firewall_endpoint_ids[each.key]
}

resource "aws_route" "firewall_tointernet_gateway" {
  for_each               = toset(["3", "4", "5"])
  route_table_id         = module.vpc_dataexfiltration.public_route_table_ids[each.key]
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}
