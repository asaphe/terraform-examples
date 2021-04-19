resource "aws_glue_catalog_database" "this" {
  name         = var.name == null ? local.name : var.name
  catalog_id   = var.catalog_id
  description  = var.description
  location_uri = var.location_uri
  parameters   = var.parameters
}