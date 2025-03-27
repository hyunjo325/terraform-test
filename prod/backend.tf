terraform {
  backend "s3" {
    bucket         = "terraform-evan-tfstate"
    key            = "prod/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

