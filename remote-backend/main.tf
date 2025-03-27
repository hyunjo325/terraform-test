resource "aws_s3_bucket" "tfstate" {
  bucket = "terraform-evan-tfstate"
  lifecycle {
    prevent_destroy = true
    ignore_changes  = all
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = all
  }
}
