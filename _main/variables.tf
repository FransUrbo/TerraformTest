variable "account_id" {}
variable "availability_zones" {}
variable "region" {}

variable "s3-cleanup" {
  description            = "File to use for the Lambda function"
  default                = "./s3-cleanup.zip"
}
