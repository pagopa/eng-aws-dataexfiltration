data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc_dataexfiltration" {
  source                       = "terraform-aws-modules/vpc/aws"
  version                      = "5.1.2"
  name                         = var.prefix
  cidr                         = "10.0.0.0/16"
  azs                          = data.aws_availability_zones.available.names
  private_subnets              = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_names         = ["${var.prefix}_private_1", "${var.prefix}_private_2", "${var.prefix}_private_3"]
  public_subnets               = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  public_subnet_names          = ["${var.prefix}_public_1", "${var.prefix}_public_2", "${var.prefix}_public_3"]
  public_dedicated_network_acl = true
  enable_nat_gateway           = true
  single_nat_gateway           = true
  enable_dns_hostnames         = true
  enable_dns_support           = true
}

module "vpc_endpoints_dataexfiltration" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.0"

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
  security_group_name_prefix = "vpc-endpoints-${var.prefix}"
  security_group_description = "VPC endpoint security group"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from subnets"
      cidr_blocks = module.vpc_dataexfiltration.private_subnets_cidr_blocks
    }
  }
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "5.13.0"

  vpc_id = module.vpc_dataexfiltration.vpc_id

  create_security_group      = true
  security_group_name_prefix = "${var.prefix}-vpc-endpoints-"
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
      private_dns_enabled = true
      dns_options = {
        private_dns_only_for_inbound_resolver_endpoint = false
      }
    }
  }
}