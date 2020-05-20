terraform {
  required_version = ">= 0.12"
  required_providers {
    google      = "~> 3.20"
    google-beta = "~> 3.20"
    helm        = "~> 1.2"
    random      = "~> 2.2"
    local       = "~> 1.4"
  }
  backend "gcs" {}
}