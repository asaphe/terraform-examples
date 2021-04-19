locals {
  name = "${lower(var.name)}-glue-catalog-table-${lower(var.environment)}"
}