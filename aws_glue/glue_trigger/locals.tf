locals {
  name = "${lower(var.name)}-glue-trigger-${lower(var.environment)}"
}