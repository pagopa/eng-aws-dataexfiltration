variable "aws_region" {
  type    = string
  default = "eu-south-1"
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
