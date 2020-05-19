locals {
  bucket_name   = "${var.prefix}-${var.name}"
  resource_name = "${var.prefix}-${var.name}"
  subnet_01     = "${var.prefix}-${var.name}-gke"
}

resource "google_compute_subnetwork" "this" {
  name          = local.subnet_01
  ip_cidr_range = "${var.ip_cidr}/${var.ip_cidr_netmask}"
  region        = var.location
  network       = data.google_compute_network.this.self_link

  secondary_ip_range = [
    {
      range_name    = "${local.resource_name}-gke-pods"
      ip_cidr_range = cidrsubnet("${var.ip_cidr}/12", 4, 4)
    },
    {
      range_name    = "${local.resource_name}-gke-services"
      ip_cidr_range = cidrsubnet("${var.ip_cidr}/12", 4, 5)
    }
  ]
}

module "gke" {
  source    = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  version   = "~>7.0"
  providers = {google = google-beta}

  project_id               = var.project_id
  name                     = local.resource_name
  regional                 = true
  region                   = var.location
  istio                    = var.istio
  network                  = data.google_compute_network.this.name
  subnetwork               = google_compute_subnetwork.this.name
  ip_range_pods            = "${local.resource_name}-gke-pods"
  ip_range_services        = "${local.resource_name}-gke-services"
  remove_default_node_pool = var.remove_default_node_pool

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
      min_count          = 1
      max_count          = 3
      disk_size_gb       = 100
      disk_type          = "pd-ssd"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = false
      preemptible        = false
      initial_node_count = 1
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
