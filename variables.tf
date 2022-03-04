#data "aws_caller_identity" "current" { }
variable "account_id" {
  description		= "Mock account ID value"
  default		= "0123456789"
}

#data "aws_availability_zones" "available" { }
variable "availability_zones" {
  type			= list(string)
  description		= "Mock number of availability zones"
  default		= [
    "eu-west-1a",
    "eu-west-1b",
    "eu-west-1c"
  ]
}

#data "aws_region" "current" {}
variable "region" {
  description		= "Mock region name"
  default		= "eu-west-1"
}

