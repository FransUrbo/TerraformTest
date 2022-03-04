terraform {
    required_version = ">= 1.1"
    required_providers {
      aws = "~> 4.3"
    }
}

provider "aws" {
  region			= var.region
  #provider			= "test-turbo"

  skip_credentials_validation	= true
  skip_requesting_account_id	= true
  skip_metadata_api_check	= true

  access_key			= "mock_access_key"
  secret_key			= "mock_secret_key"
}
