data "aws_ami" "aws" {
  filter {
    name   = "name"
    values = ["al2023-ami-2023.6.20241010.0-kernel-6.1-x86_64"]
  }
}

module "ec2_instance_dataexfiltration_one" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.7.0"

  name = "${local.project}-ec2-one"

  instance_type = "t3a.nano"
  ami           = data.aws_ami.aws.id

  subnet_id              = element(module.vpc_dataexfiltration.private_subnets, 0)
  vpc_security_group_ids = [module.security_group_dataexfiltration_one.security_group_id]

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for first EC2 instance"
  iam_role_use_name_prefix    = true
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

module "security_group_dataexfiltration_one" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name         = "${local.project}-securitygroup-ec2-one"
  description  = "Security Group for EC2 Instance Egress"
  vpc_id       = module.vpc_dataexfiltration.vpc_id
  egress_rules = ["https-443-tcp"]
  egress_with_cidr_blocks = [
    {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      description = "User-service ports"
      cidr_blocks = var.vpc_cidr_block
    }
  ]
}

module "ec2_instance_dataexfiltration_sni_listener" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.7.0"

  name = "${local.project}-ec2-sni-listener"

  instance_type = "t3a.nano"
  ami           = data.aws_ami.aws.id

  vpc_security_group_ids = [module.security_group_dataexfiltration_sni_listener.security_group_id]

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for first EC2 instance"
  iam_role_use_name_prefix    = true
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  user_data                   = file("init-sni-listener.sh")
  user_data_replace_on_change = true
}

module "security_group_dataexfiltration_sni_listener" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${local.project}-securitygroup-ec2-sni-listener"
  description = "Allow ingress/egress"

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "allow-ingress-http"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "allow-ingress-https"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = -1
      to_port     = -1
      protocol    = -1
      description = "allow-egress-all"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

output "ec2_sni_listener_public_ip" {
  value = module.ec2_instance_dataexfiltration_sni_listener.public_ip
}
