locals {
  bucket_name   = "${var.prefix}-${var.name}"
  resource_name = "${var.prefix}-${var.name}"
  subnet_01     = "${var.prefix}-${var.name}-gke"
}

module "gke-network" {
  source  = "terraform-google-modules/network/google"

  project_id   = var.project_id
  network_name = local.resource_name
  description  = "Owner: ${local.resource_name} Project: ${var.name}"

  subnets = [
      {
          subnet_name           = local.subnet_01
          subnet_ip             = cidrsubnet("${var.vpc_cidr}", 4, 2)
          subnet_region         = var.region
      },
  ]

  secondary_ranges = {
    "${local.subnet_01}" = [
      {
        range_name    = "${local.subnet_01}-pods"
        ip_cidr_range = cidrsubnet("${var.vpc_cidr}", 3, 2)
      },
      {
        range_name    = "${local.subnet_01}-services"
        ip_cidr_range = cidrsubnet("${var.vpc_cidr}", 2, 2)
      },
    ]
  }
}

module "gke" {
  source    = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  version   = "~>7.0"
  providers = {google = google-beta}

  project_id                 = var.project_id
  name                       = local.resource_name
  regional                   = var.regional_cluster
  region                     = var.region
  istio                      = var.istio
  network                    = module.gke-network.network_name
  subnetwork                 = module.gke-network.subnets_names[0]
  ip_range_pods              = "${local.resource_name}-gke-pods"
  ip_range_services          = "${local.resource_name}-gke-services"
  remove_default_node_pool   = var.remove_default_node_pool
  network_policy             = var.network_policy
  http_load_balancing        = var.http_load_balancing
  horizontal_pod_autoscaling = var.horizontal_pod_autoscaling

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      ]

    default-node-pool = []
  }

  node_pools = [
    {
      name               = "${local.resource_name}-node-pool"
      machine_type       = var.machine_type
      min_count          = var.node_pool_min
      max_count          = var.node_pool_max
      disk_size_gb       = var.disk_size_gb
      disk_type          = var.disk_type
      image_type         = var.image_type
      auto_repair        = var.auto_repair
      auto_upgrade       = var.auto_upgrade
      preemptible        = var.preemptible
      initial_node_count = var.initial_node_count
    },
  ]

  node_pools_metadata = {
    all        = {}
    node_pools = {
      Cluster = local.resource_name
      Owner   = local.resource_name
      Project = var.project_id
    }
  }

  node_pools_tags = {
    all        = []
    node_pools = [
      "local.resource_name",
    ]
  }
}

module "service_accounts" {
  source        = "terraform-google-modules/service-accounts/google"
  version       = "~>2.0.2"

  project_id    = var.project_id
  names         = ["${local.resource_name}-vault-service-account"]
  project_roles = ["${var.project_id}=>roles/cloudkms.cryptoKeyEncrypterDecrypter", "${var.project_id}=>roles/storage.objectAdmin"]
  generate_keys = true
}

module "gcs_bucket" {
  source  = "terraform-google-modules/cloud-storage/google"
  version = "~> 1.5"

  project_id      = var.project_id
  location        = var.bucket_location
  names           = ["vault-data"]
  prefix          = local.resource_name
  storage_class   = var.bucket_storage_class
  set_admin_roles = true

  bucket_admins = {
    vault-data = module.service_accounts.iam_email
  }

  versioning = {
    vault-data = var.bucket_versioning
  }

  force_destroy = {
    vault-data = true
  }

  labels = {
    owner   = "${local.resource_name}"
    project = "${var.project_id}"
  }
}

# Disable to use existing key_ring
module "kms" {
  source    = "terraform-google-modules/kms/google"
  version   = "~>1.1.0"

  project_id          = var.project_id
  location            = var.kms_location
  keyring             = var.kms_key_ring
  keys                = [var.kms_crypto_key]
  set_owners_for      = [var.kms_crypto_key]
  owners              = [module.service_accounts.iam_email]
  prevent_destroy     = var.kms_prevent_destroy
  key_rotation_period = var.kms_rotation_period
}

resource "google_kms_crypto_key_iam_binding" "vault-encrypterdecrypter" {
  crypto_key_id = data.google_kms_crypto_key.vault_key.self_link
  members       = [module.service_accounts.iam_email,]
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
}

resource "google_kms_crypto_key_iam_binding" "vault-viewer" {
  crypto_key_id = data.google_kms_crypto_key.vault_key.self_link
  members       = [module.service_accounts.iam_email,]
  role          = "roles/viewer"
}
