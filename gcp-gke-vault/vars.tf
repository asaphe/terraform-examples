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

variable "region" {
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

variable "kms_prevent_destroy" {
  type    = bool
  default = true
}

variable "kms_key_ring" {
  type    = string
  default = "vault-auto-unseal"
}

variable "kms_crypto_key" {
  type    = string
  default = "vault-auto-unseal"
}

variable "kms_rotation_period" {
  type        = string
  description = "Every time this period passes, generate a new CryptoKeyVersion and set it as the primary"
  default     = "9000000s"
}

variable "machine_type" {
  type    = string
  default = "n1-standard-1"
}

variable "remove_default_node_pool" {
  type    = string
  default = true
}

variable "regional_cluster" {
  type        = bool
  description = "Regional GKE Cluster"
  default     = true
}

variable "kubernetes_version" {
  type    = string
  default = "1.16.8-gke.15"
}

variable "node_version" {
  type    = string
  default = "1.16.8-gke.15"
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

variable "vpc_cidr" {
  type        = string
  description = "CIDR for the VPC including netmask [172.30.0.0/12]"
  default     = "172.30.0.0/12"
}

variable "node_pool_min" {
  type        = number
  description = "Node pool minimum size"
  default     = 1
}

variable "node_pool_max" {
  type        = number
  description = "Node pool maximum size"
  default     = 3
}

variable "disk_size_gb" {
  type        = number
  description = "Node disk size"
  default     = 40
}

variable "disk_type" {
  type        = string
  description = "Node disk type"
  default     = "pd-ssd"
}

variable "image_type" {
  type        = string
  description = "choose the operating system image that runs on each node [COS, COS_containerd, etc,.]"
  default     = "COS_containerd"
}

variable "auto_repair" {
  type        = bool
  description = "GKE Auto repair"
  default     = true
}

variable "auto_upgrade" {
  type        = bool
  description = "GKE Auto upgrade"
  default     = false
}

variable "preemptible" {
  type        = bool
  description = "GKE preemptible nodes"
  default     = false
}

variable "initial_node_count" {
  type        = number
  description = "Initial node count"
  default     = 1
}

variable "network_policy" {
  type        = bool
  description = "Activate network policy"
  default     = false
}

variable "http_load_balancing" {
  type        = bool
  description = "GKE HTTP Load Balancing Addon"
  default     = false
}

variable "horizontal_pod_autoscaling" {
  type        = bool
  description = "Enable horizontal pod autoscaling"
  default     = false
}

variable "maintenance_start_time" {
  type        = string
  description = "Time window specified for daily or recurring maintenance operations in RFC3339 format [05:00]"
  default     = ""
}