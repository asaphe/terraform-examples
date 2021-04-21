# AWS Glue Job

This module sets up an `aws_glue_job` resource.

## Terraform Version

This module was built and tested with Terraform `14.6`. Additional testing was done with Terraform `13.5`

## Recommended Usage

Create a module directory to instantiate this module. it can be combined with other Glue modules in the same `tf` file and the `outputs` of each module can be used for downstream variables.

### Usage Example

```hcl
## main.tf
locals {
  tags = merge(var.tags,var.more_tags)
}

module "glue_job" {
  source = "../shared-modules/aws_glue/glue_job"

  name                   = local.name
  role_arn               = var.role_arn
  command                = var.command
  description            = var.description
  connections            = var.connections
  additional_connections = var.additional_connections
  default_arguments      = var.default_arguments
  execution_property     = var.execution_property
  glue_version           = var.glue_version
  max_capacity           = var.max_capacity
  max_retries            = var.max_retries
  notification_property  = var.notification_property
  security_configuration = var.security_configuration
  worker_type            = var.worker_type
  number_of_workers      = var.number_of_workers
  environment            = var.environment
  tags                   = local.tags
}

## outputs.tf
output "glue_job_id" {
  description = "Glue job name"
  value       = module.glue_job.glue_job_id
}

output "glue_job_arn" {
  description = "Amazon Resource Name (ARN) of Glue Job"
  value       = module.glue_job.glue_job_arn
}
```

## Variables

Please review `variables.tf`. the description of each variable denotes if the variable is required or optional and includes a description about the variable function.

> Please ensure you're passing the correct structure for any variable with the type `any`

### Required

```raw
name – (Required) The name you assign to this job. It must be unique in your account.
role_arn – (Required) The ARN of the IAM role associated with this job.
```

* Command (Required Block)

```raw
script_location - (Required) Specifies the S3 path to a script that executes a job.
```

## Outputs

1. id
2. arn
