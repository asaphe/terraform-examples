locals {
  dynamodb_table_name = "ue1-terraform-state-lock"
}

resource "aws_dynamodb_table" "tf-state" {
  attribute {
    name = "LockID"
    type = "S"
  }

  hash_key = "LockID"

  read_capacity  = 5
  write_capacity = 5

  name = local.dynamodb_table_name

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(var.global_tags, { name = local.dynamodb_table_name, Billing = "terraform-dynamodb-table" })
}