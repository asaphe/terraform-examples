variable "environment" {
  type        = string
  description = "Environment name"
  default     = null
}

variable "name" {
  type        = string
  description = "(Required) Name of the table. For Hive compatibility, this must be entirely lowercase."
  default     = null
}

variable "database_name" {
  type        = string
  description = "(Required) Name of the metadata database where the table metadata resides. For Hive compatibility, this must be all lowercase."
  default     = null
}

variable "catalog_id" {
  type        = string
  description = "(Optional) ID of the Glue Catalog and database to create the table in. If omitted, this defaults to the AWS Account ID plus the database name."
  default     = null
}

variable "description" {
  type        = string
  description = "(Optional) Description of the table."
  default     = null
}

variable "owner" {
  type        = string
  description = "(Optional) Owner of the table."
  default     = null
}

variable "retention" {
  type        = number
  description = "(Optional) Retention time for this table."
  default     = null
}

variable "storage_descriptor" {
  type        = list(any)
  description = "(Optional) A storage descriptor object containing information about the physical storage of this table. You can refer to the Glue Developer Guide for a full explanation of this object."
  default     = []
}

variable "partition_keys" {
  type = list(object({
    name = string
    type = string
  }))
  description = "(Optional) A list of columns by which the table is partitioned. Only primitive types are supported as partition keys. see Partition Keys below."
  default     = []
}

variable "view_original_text" {
  type        = string
  description = "(Optional) If the table is a view, the original text of the view; otherwise null."
  default     = null
}

variable "view_expanded_text" {
  type        = string
  description = "(Optional) If the table is a view, the expanded text of the view; otherwise null."
  default     = null
}

variable "table_type" {
  type        = string
  description = "(Optional) The type of this table (EXTERNAL_TABLE, VIRTUAL_VIEW, etc.). While optional, some Athena DDL queries such as ALTER TABLE and SHOW CREATE TABLE will fail if this argument is empty."
  default     = null
}

variable "parameters" {
  type        = map(string)
  description = "(Optional) Properties associated with this table, as a list of key-value pairs."
  default     = {}
}

variable "partition_index" {
  type        = map(object({
    index_name = string
    keys       = string
  }))
  description = "(Optional) A list of partition indexes."
  default     = {}
}