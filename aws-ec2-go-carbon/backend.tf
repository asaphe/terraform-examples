terraform {
  backend "s3" {
    bucket               = "terraform-state"
    workspace_key_prefix = "ec2-go-carbon"
    key                  = "terraform.tfstate"
    region               = "us-east-1"
    encrypt              = "true"
    dynamodb_table       = "infoprtct-terraform-state-locking"
    profile              = "us1"
  }
}