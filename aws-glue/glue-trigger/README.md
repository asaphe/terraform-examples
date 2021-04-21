# AWS Glue Trigger

This module sets up an `aws_glue_trigger` resource.

## Terraform Version

This module was built and tested with Terraform `14.6`. Additional testing was done with Terraform `13.5`

## Recommended Usage

Create a module directory to instantiate this module. it can be combined with other Glue modules in the same `tf` file and the `outputs` of each module can be used for downstream variables.

### Usage Example

* variables defined in the calling module

```hcl
trigger_name        = "test"
trigger_description = "test trigger"
trigger_type        = "ON_DEMAND"

trigger_actions = {
  job_name = "test"
  arguments = {
    "myarguemnt" = "test"
  }
}

trigger_predicate = {
  logical    = "AND"
  conditions = {
    job_name = "test"
  }
}

trigger_tags = {
  Environment   = "dev"
  support_level = "development"
}

trigger_more_tags = {
  "Tag1"  = "Tag1"
  "Tag12" = "Tag12"
}
```

* Instantiation

```hcl
locals {
  trigger_tags = merge(var.trigger_tags,var.trigger_more_tags)
}

module "glue_trigger" {
  source = "../shared-modules/aws_glue/glue_trigger"

  name          = var.trigger_name
  description   = var.trigger_description
  type          = var.trigger_type
  actions       = var.trigger_actions
  enabled       = var.trigger_enabled
  predicate     = var.trigger_predicate
  schedule      = var.trigger_schedule
  workflow_name = var.trigger_workflow_name
  environment   = var.environment
  tags          = local.trigger_tags
}


output "glue_trigger_id" {
  description = "Glue trigger Name"
  value       = module.glue_trigger.glue_trigger_id
}

output "glue_trigger_arn" {
  description = "Glue trigger ARN"
  value       = module.glue_trigger.glue_trigger_arn
}
```

## Variables

Please review `variables.tf`. the description of each variable denotes if the variable is required or optional and includes a description about the variable function.

> Please ensure you're passing the correct structure for any variable with the type `any`

### Required

```raw
type – (Required) The type of trigger. Valid values are CONDITIONAL, ON_DEMAND, and SCHEDULED.
```

* Actions (Required Block)

While the block itself is *required* none of the attributes are required. it can be left as an empty block.

* Predicate (Optional Block `Required when trigger type is CONDITIONAL`)

```raw
conditions - (Required) A list of the conditions that determine when the trigger will fire.
```

## Outputs

1. id
2. arn
