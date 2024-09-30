module "ec2_instance_dataexfiltration_one" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.7.0"

  name = "ec2-${var.prefix}-one"

  instance_type = "t3.micro"
  ami           = "ami-06d4fa1e7c1b6d9b7"

  subnet_id              = element(module.vpc_dataexfiltration.private_subnets, 0)
  vpc_security_group_ids = [module.security_group_dataexfiltration_one.security_group_id]

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for first EC2 instance"
  iam_role_use_name_prefix    = true
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

module "ec2_instance_dataexfiltration_two" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.7.0"

  name = "ec2-${var.prefix}-two"

  instance_type = "t3.micro"
  ami           = "ami-06d4fa1e7c1b6d9b7"

  subnet_id              = element(module.vpc_dataexfiltration.public_subnets, 0)
  vpc_security_group_ids = [module.security_group_dataexfiltration_two.security_group_id]

}

module "security_group_dataexfiltration_one" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name         = "${var.prefix}-ec2-one"
  description  = "Security Group for EC2 Instance Egress"
  vpc_id       = module.vpc_dataexfiltration.vpc_id
  egress_rules = ["https-443-tcp"]
  egress_with_cidr_blocks = [
    {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      description = "User-service ports"
      cidr_blocks = "10.0.0.0/24"
  }]
}

module "security_group_dataexfiltration_two" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.prefix}-ec2-two"
  description = "Security Group for second EC2 Instance Egress"
  vpc_id      = module.vpc_dataexfiltration.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      description = "User-service ports"
      cidr_blocks = "10.0.0.0/24"
  }]
}