variable "environment" {
  type        = string
  description = "Environment name"
  default     = null
}

variable "actions" {
  type        = any
  description = "(Required) A map of actions initiated by this trigger when it fires."
  default     = null
}

variable "type" {
  type        = string
  description = "(Required) The type of trigger. Valid values are CONDITIONAL, ON_DEMAND, and SCHEDULED."
  default     = null
}

variable "name" {
  type        = string
  description = "(Required) The name of the trigger."
  default     = null
}

variable "description" {
  type        = string
  description = "(Optional) A description of the new trigger."
  default     = null
}

variable "enabled" {
  type        = bool
  description = "(Optional) Start the trigger. Defaults to true."
  default     = true
}

variable "predicate" {
  type        = any
  description = "(Optional) A predicate to specify when the new trigger should fire. Required when trigger type is CONDITIONAL. See Predicate Below."
  default     = {}
}

variable "schedule" {
  type        = string
  description = "(Optional) A cron expression used to specify the schedule. Time-Based Schedules for Jobs and Crawlers"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Key-value map of resource tags"
  default     = {}
}

variable "workflow_name" {
  type        = string
  description = "(Optional) A workflow to which the trigger should be associated to. Every workflow graph (DAG) needs a starting trigger (ON_DEMAND or SCHEDULED type) and can contain multiple additional CONDITIONAL triggers."
  default     = null
}