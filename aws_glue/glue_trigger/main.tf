resource "aws_glue_trigger" "this" {
  name          = var.name == null ? local.name : var.name
  description   = var.description
  type          = var.type
  enabled       = var.enabled
  schedule      = var.schedule
  workflow_name = var.workflow_name

  dynamic "actions" {
    iterator = actions
    for_each = var.actions

    content {
      arguments              = lookup(var.actions, "arguments", null)
      crawler_name           = lookup(var.actions, "job_name", null) == null ? lookup(var.actions, "crawler_name", null) : null
      job_name               = lookup(var.actions, "crawler_name", null) == null ? lookup(var.actions, "job_name", null) : null
      timeout                = lookup(var.actions, "timeout", null)
      security_configuration = lookup(var.actions, "security_configuration", null)
      notification_property  {
        notify_delay_after = lookup(var.actions,"notify_delay_after", 1)
      }
    }
  }

  dynamic "predicate" {
    iterator = predicate
    for_each = var.predicate

    content {
      logical = lookup(var.predicate, "logical", null)
      conditions {
        job_name         = lookup(var.predicate, "state", null) != null && lookup(var.predicate, "crawler_name", null) == null ? lookup(var.predicate, "job_name", null) : null
        state            = lookup(var.predicate, "job_name", null) != null ? lookup(var.predicate, "state", null) : null
        crawler_name     = lookup(var.predicate, "crawl_state", null) != null && lookup(var.predicate, "job_name", null) == null ? lookup(var.predicate, "crawler_name", null) : null
        crawl_state      = lookup(var.predicate, "crawler_name", null) != null ? lookup(var.predicate, "crawl_state", null) : null
        logical_operator = lookup(var.predicate, "logical_operator", null)
      }
    }
  }

  tags = merge(
    var.tags,
    {
      "Name" = local.name
    },
  )
}