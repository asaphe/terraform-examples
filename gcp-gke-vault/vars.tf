variable "project_id" {
  type    = string
  default = "my-project"
}

variable "prefix" {
  type    = string
  default = "test"
}

variable "name" {
  type    = string
  default = "vault-istio"
}

variable "location" {
  type    = string
  default = "us-central1"
}

variable "istio" {
  type    = bool
  default = true
}

variable "bucket_versioning" {
  type    = bool
  default = false
}

variable "bucket_location" {
  type    = string
  default = "US"
}

variable "bucket_storage_class" {
  type        = string
  default     = "MULTI_REGIONAL"
}

variable "kms_location" {
  type    = string
  default = "global"
}

variable "kms_key_ring" {
  type    = string
  default = "vault-auto-unseal"
}

variable "kms_prevent_destroy" {
  type    = bool
  default = true
}

variable "kms_crypto_key" {
  type    = string
  default = "vault-auto-unseal"
}

variable "machine_type" {
  type    = string
  default = "n1-standard-1"
}

variable "remove_default_node_pool" {
  type    = string
  default = true
}

variable "kubernetes_version" {
  type    = string
  default = "1.15.11-gke.3"
}

variable "node_version" {
  type    = string
  default = "1.15.11-gke.3"
}

variable "vpc_name" {
  type        = string
  description = "An existing VPC name"
  default     = "test-gke-istio"
}

variable "subnetwork_name" {
  type        = string
  description = "An existing Subnet name"
  default     = "test-gke-istio"
}

variable "ip_cidr" {
  type    = string
  default = "172.30.0.0"
}

variable "ip_cidr_netmask" {
  type    = string
  default = "24"
}
