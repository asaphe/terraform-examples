# AWS Glue Job

This module sets up an `aws_glue_catalog_database` resource.

## Terraform Version

This module was built and tested with Terraform `14.6`. Additional testing was done with Terraform `13.5`

## Recommended Usage

Create a module directory to instantiate this module. it can be combined with other Glue modules in the same `tf` file and the `outputs` of each module can be used for downstream variables.

## Variables

Please review `variables.tf`. the description of each variable denotes if the variable is required or optional and includes a description about the variable function.

> Please ensure you're passing the correct structure for any variable with the type `any`

### Required

```raw
name - (Required) The name of the database.
```

## Outputs

1. id
2. arn
