locals {
  name = "${lower(var.name)}-glue-db-${lower(var.environment)}"
}