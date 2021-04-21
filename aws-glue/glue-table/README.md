# AWS Glue Catalog Table

This module create an `aws_glue_catalog_table` resource.

## Terraform Version

This module was built and tested with Terraform `14.6`. Additional testing was done with Terraform `13.5`

## Recommended Usage

Create a module directory to instantiate this module. it can be combined with other Glue modules in the same `tf` file and the `outputs` of each module can be used for downstream variables.

### Usage Example

* variables defined in the calling module

```hcl
## example_vars.tfvars
environment   = "dev"
name          = "test"
database_name = "test"

partition_keys = [
  {
    name = "test"
    type = "string"
  },
  {
    name = "test2"
    type = "something"
  },
]

storage_descriptor = [
  {
  location     = "test_location"
  input_format = "test_format"
  columns = [
    {
      name = "column1"
      type = "test1"
    },
    {
      name = "column2"
      type = "test"
    },
  ]
  },
]

## main.tf
module "glue_catalog_table" {
  source = "../shared-modules/aws_glue/glue_table"

  environment        = var.environment == null ? local.environment : var.environment
  name               = var.name
  database_name      = var.database_name
  catalog_id         = var.catalog_id
  description        = var.description
  owner              = var.owner
  retention          = var.retention
  storage_descriptor = var.storage_descriptor
  view_original_text = var.view_original_text
  view_expanded_text = var.view_expanded_text
  table_type         = var.table_type
  parameters         = var.parameters
  partition_keys     = var.partition_keys
  partition_index    = var.partition_index
}
```

## Variables

Please review `variables.tf`. the description of each variable denotes if the variable is required or optional and includes a description about the variable function.

### Required

```raw
name - (Required) Name of the table. For Hive compatibility, this must be entirely lowercase.
database_name - (Required) Name of the metadata database where the table metadata resides. For Hive compatibility, this must be all lowercase.
```

* Partition Index (Optional Block)

```raw
index_name - (Required) The name of the partition index.
keys - (Required) The keys for the partition index.

```

* Partition Keys (Optional Block)

```raw
name - (Required) The name of the Partition Key.
```

* Column  (Optional Block)

```raw
name - (Required) The name of the Column.
```

* Sort Columns  (Optional Block)

```raw
column - (Required) The name of the column.
sort_order - (Required) Indicates that the column is sorted in ascending order (== 1), or in descending order (==0).
```

* Schema Reference  (Optional Block)

```raw
schema_version_number - (Required) The version number of the schema.
```

## Outputs

1. id
2. arn
