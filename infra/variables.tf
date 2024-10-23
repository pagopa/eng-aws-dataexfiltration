variable "aws_region" {
  type = string
  # default = "eu-south-1" # Milan
  default = "eu-west-3" # Paris
}

variable "tags" {
  type        = map(string)
  description = "Data Exfiltarion Solution"
  default = {
    CreatedBy = "Terraform"
  }
}

variable "prefix" {
  description = "Resorce prefix"
  type        = string
  default     = "dex"
}

variable "vpc_cidr_block" {
  description = "vpc cidr block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_nat_gateway_subnets" {
  description = "NAT Gateway subnets"
  type = object({
    name = string
    cidr = list(string)
    type = string
  })
  default = {
    name = "natgw"
    cidr = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
    type = "public"
  }
}

variable "vpc_firewall_subnets" {
  description = "Firewall subnets"
  type = object({
    name = string
    cidr = list(string)
    type = string
  })
  default = {
    name = "fw"
    cidr = ["10.0.104.0/24", "10.0.105.0/24", "10.0.106.0/24"]
    type = "public"
  }
}

variable "vpc_load_balancer_subnets" {
  description = "Application load balancer subnets"
  type = object({
    name = string
    cidr = list(string)
    type = string
  })
  default = {
    name = "lb"
    cidr = ["10.0.107.0/24", "10.0.108.0/24", "10.0.109.0/24"]
    type = "public"
  }
}

variable "vpc_compute_subnets" {
  description = "Compute subnets"
  type = object({
    name = string
    cidr = list(string)
    type = string
  })
  default = {
    name = "compute"
    cidr = ["10.0.1.0/24", "10.0.2.0/24", "10.0.2.0/24"]
    type = "private"
  }
}