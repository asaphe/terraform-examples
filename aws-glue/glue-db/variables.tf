variable "environment" {
  type        = string
  description = "Environment name"
  default     = null
}

variable "name" {
  type        = string
  description = "(Required) The name of the database."
  default     = null
}

variable "catalog_id" {
  type        = string
  description = "(Optional) ID of the Glue Catalog to create the database in. If omitted, this defaults to the AWS Account ID."
  default     = null
}

variable "description" {
  type        = string
  description = "(Optional) Description of the database."
  default     = null
}

variable "location_uri" {
  type        = string
  description = "(Optional) The location of the database (for example, an HDFS path)."
  default     = null
}

variable "parameters" {
  type        = map(string)
  description = "(Optional) A list of key-value pairs that define parameters and properties of the database."
  default     = {}
}