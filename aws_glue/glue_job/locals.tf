locals {
  name = "${lower(var.name)}-glue-job-${lower(var.environment)}"
}