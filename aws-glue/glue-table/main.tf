resource "aws_glue_catalog_table" "this" {
  name               = var.name == null ? local.name : var.name
  database_name      = var.database_name
  catalog_id         = var.catalog_id
  description        = var.description
  owner              = var.owner
  retention          = var.retention
  view_original_text = var.view_original_text
  view_expanded_text = var.view_expanded_text
  table_type         = var.table_type
  parameters         = var.parameters

  dynamic "partition_keys" {
    iterator = partition_keys
    for_each = var.partition_keys
    content {
      name    = lookup(partition_keys.value, "name", null)
      type    = lookup(partition_keys.value, "type", null)
      comment = lookup(partition_keys.value, "comment", null)
    }
  }

  dynamic "partition_index" {
    iterator = partition_index
    for_each = var.partition_index
    content {
      index_name = lookup(partition_index.value, "index_name", null)
      keys       = lookup(partition_index.value, "keys", null)
    }
  }

  dynamic "storage_descriptor" {
    iterator = storage_descriptor
    for_each = var.storage_descriptor
    content {
      location     = lookup(storage_descriptor.value, "location", null)
      input_format = lookup(storage_descriptor.value, "input_format", null)
      dynamic "columns" {
        iterator = column
        for_each = lookup(storage_descriptor.value, "columns", {})
        content {
          name    = lookup(column.value, "name", null)
          type    = lookup(column.value, "type", null)
          comment = lookup(column.value, "comment", null)
        }
      }
      dynamic "ser_de_info" {
        iterator = ser_de_info
        for_each = lookup(storage_descriptor.value, "ser_de_info", [])
        content {
          name                  = lookup(ser_de_info.value, "name", null)
          parameters            = lookup(ser_de_info.value, "parameters", null)
          serialization_library = lookup(ser_de_info.value, "serialization_library", null)
        }
      }
      dynamic "skewed_info" {
        iterator = skewed_info
        for_each = lookup(storage_descriptor.value, "skewed_info", [])
        content {
          skewed_column_names               = lookup(skewed_info.value, "skewed_column_names", null)
          skewed_column_values              = lookup(skewed_info.value, "skewed_column_values", null)
          skewed_column_value_location_maps = lookup(skewed_info.value, "skewed_column_value_location_maps", null)
        }
      }
      dynamic "schema_reference" {
        iterator = schema_reference
        for_each = lookup(storage_descriptor.value, "schema_reference", {})
        content {
          schema_version_id     = lookup(schema_reference.value, "schema_version_id", null)
          schema_version_number = lookup(schema_reference.value, "schema_version_number", null)
          dynamic "schema_id" {
            iterator = schema_id
            for_each = lookup(schema_reference.value, "schema_id")
            content {
              schema_arn    = lookup(schema_id.value, "schema_arn", null)
              schema_name   = lookup(schema_id.value, "schema_name", null)
              registry_name = lookup(schema_id.value, "registry_name", null)
            }
          }
        }
      }
      dynamic "sort_columns" {
        iterator = sort_columns
        for_each = lookup(storage_descriptor.value,"sort_columns", {})
        content {
          column     = lookup(sort_columns.value,"column")
          sort_order = lookup(sort_columns.value,"sort_order")
        }
      }
    }
  }
}