# provider.tf
provider "aws" {
  region  = var.region
  profile = var.profile
}

