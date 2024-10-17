variable "aws_region" {
  type    = string
  default = "eu-central-1" # Milan
  # default = "eu-west-3" # Paris
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