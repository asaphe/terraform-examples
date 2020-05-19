terraform {
  required_version = ">= 0.12.21"

  required_providers {
    aws   = ">= 2.60.0"
    tls   = ">= 2.1.1"
    null  = ">= 2.1.2"
    local = ">= 1.4.0"
  }
}