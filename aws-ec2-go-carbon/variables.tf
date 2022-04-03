variable "environment" {
  type        = string
  description = "(Optional) Override the generated environment name"
  default     = null
}

variable "username" {
  type        = string
  description = "(Required) username"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "(Optional) A map of tags to assign to the resource."
  default     = null
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block, example: 10.99.0.0/16"
  default     = null
}

variable "availability_zone" {
  type        = string
  description = "AWS Availability zone [example: use1-az1]"
  default     = null
}

variable "secondary_availability_zone" {
  type        = string
  description = "AWS Availability zone [example: use1-az1]"
  default     = null
}

variable "instance_type" {
  type        = string
  description = "AWS Instance Type"
  default     = null
}

variable "instance_monitoring" {
  type        = bool
  description = "Enable or turn off detailed monitoring for your instance"
  default     = false
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile"
  default     = null
}

variable "enable_volume_tags" {
  type        = bool
  description = "Whether to enable volume tags (if enabled it conflicts with root_block_device tags)"
  default     = true
}

variable "go-carbon-conf" {
  type = object({
    max-cpu = number
    workers = number
  })
  description = "Go-carbon settings. used in templating the configuration file"
  default     = null
}

variable "run_provisioner" {
  type        = number
  description = "The instance private IP is required to run the provisioner. use this variable to control execution"
  default     = 0
}

variable "ebs_volume_size" {
  type        = number
  description = "The attached EBS volume size [i.e /data]"
  default     = null
}

variable "ebs_volume_delete_on_termination" {
  type        = bool
  description = "Delete the attached EBS volume on termination"
  default     = false
}

variable "ebs_volume_iops" {
  type        = number
  description = "Consistent baseline rate of 3,000 IOPS and 125 MiB/s, included with the price of storage. You can provision additional IOPS (up to 16,000)."
  default     = null
}

variable "ebs_volume_throughput" {
  type        = number
  description = "Consistent baseline rate of 3,000 IOPS and 125 MiB/s, included with the price of storage. You can provision additional throughput (up to 1,000 MiB/s) for an additional cost."
  default     = null
}

variable "create_ebs_volume" {
  type        = bool
  description = "Create Root and EBS volume"
  default     = true
}

variable "associate_public_ip_address" {
  type        = bool
  description = "Whether to associate a public IP address with an instance in a VPC"
  default     = false
}