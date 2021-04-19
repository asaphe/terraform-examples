variable "environment" {
  type        = string
  description = "Environment name"
  default     = null
}

variable "name" {
  type        = string
  description = "(Required) The name you assign to this job. It must be unique in your account."
  default     = null
}

variable "role_arn" {
  type        = string
  description = "(Required) The ARN of the IAM role associated with this job."
  default     = null
}

variable "command" {
  type        = map(any)
  description = "(Required) The command of the job."
  default     = null
}

variable "description" {
  type        = string
  description = "(Optional) Description of the job."
  default     = null
}

variable "connections" {
  type        = list(string)
  description = "(Optional) The list of connections used for this job."
  default     = []
}

variable "additional_connections" {
  type        = list(string)
  description = "(Optional) The list of connections used for the job."
  default     = []
}

variable "default_arguments" {
  type        = map(any)
  description = "(Optional) The map of default arguments for this job. You can specify arguments here that your own job-execution script consumes, as well as arguments that AWS Glue itself consumes. For information about how to specify and consume your own Job arguments, see the Calling AWS Glue APIs in Python topic in the developer guide. For information about the key-value pairs that AWS Glue consumes to set up your job, see the Special Parameters Used by AWS Glue topic in the developer guide."
  default     = {
    "--job-language"                        = "scala"
    "--enable-continuous-cloudwatch-log"    = "true"
    "--enable-continuous-log-filter"        = "true"
    "--enable-metrics"                      = ""
  }
}

variable "non_overridable_arguments" {
  type        = map(any)
  description = "(Optional) Non-overridable arguments for this job, specified as name-value pairs."
  default     = {}
}

variable "execution_property" {
  type        = map(any)
  description = "(Optional) Execution property of the job."
  default     = {}
}

variable "glue_version" {
  type        = string
  description = "(Optional) The version of glue to use, for example '1.0'. For information about available versions, see the AWS Glue Release Notes."
  default     = null
}

variable "max_capacity" {
  type        = string
  description = "(Optional) The maximum number of AWS Glue data processing units (DPUs) that can be allocated when this job runs. Required when pythonshell is set, accept either 0.0625 or 1.0."
  default     = null
}

variable "max_retries" {
  type        = number
  description = "(Optional) The maximum number of times to retry this job if it fails."
  default     = null
}

variable "notification_property" {
  type        = map(any)
  description = "(Optional) Notification property of the job."
  default     = {}
}

variable "timeout" {
  type        = number
  description = "(Optional) The job timeout in minutes. The default is 2880 minutes (48 hours)."
  default     = 2880
}

variable "security_configuration" {
  type        = string
  description = "(Optional) The name of the Security Configuration to be associated with the job."
  default     = null
}

variable "worker_type" {
  description = "(Optional) The type of predefined worker that is allocated when a job runs. Accepts a value of Standard, G.1X, or G.2X."
  default     = null
}

variable "number_of_workers" {
  type        = number
  description = "(Optional) The number of workers of a defined workerType that are allocated when a job runs."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "(Optional) A map of tags to be applied to resources in this module"
  default     = {}
}