variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks to be allowed to access the master instances"
}

variable "region" {
  description = "AWS region to create the resources in"
  type        = string
  default     = "us-east-1"
}

variable "key_name" {
  description = "Amazon EC2 key pair that can be used to ssh to the created instance."
  type        = string
  default     = "my-key"
}

variable "key_location" {
  description = "The location to which the generated private key should be saved to."
  type        = string
  default     = "/tmp"
}

variable "user_tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "prefix" {
  type        = string
  default     = "my"
  description = "will be inserted as the prefix of names"
}

variable "project" {
  type        = string
  default     = "test"
  description = "used in names, will be inserted after the prefix"
}

variable "instance_count" {
  description = "Number of instances to launch"
  type        = number
  default     = 3
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "t2.medium"
}

variable "root_ebs_volume_type" {
  description = "EBS Volume type ['gp2', 'io1', 'sc1' or 'st1']"
  type        = string
  default     = "gp2"
}

variable "root_ebs_volume_size" {
  description = "EBS Volume size"
  type        = number
  default     = 20
}


variable "ebs_volume_type" {
  description = "EBS Volume type ['gp2', 'io1', 'sc1' or 'st1']"
  type        = string
  default     = "st1"
}

variable "ebs_volume_size" {
  description = "EBS Volume size"
  type        = number
  default     = 40
}


variable "availability_zones" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_cidr" {
  description = "AWS VPC CIDR block"
  type        = string
  default     = "172.30.0.0/16"
}

variable "public_ip" {
  description = "Public IP [true/false]"
  type        = bool
  default     = false
}
