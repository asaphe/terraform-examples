data "google_client_config" "current" {}

data "google_kms_key_ring" "vault" {
  project  = var.project_id
  name     = var.kms_key_ring
  location = var.kms_location
}

data "google_kms_crypto_key" "vault_key" {
  depends_on = [data.google_kms_key_ring.vault]

  name     = var.kms_crypto_key
  key_ring = data.google_kms_key_ring.vault.self_link
}

data "google_compute_network" "this" {
  name = var.vpc_name
}

data "google_compute_subnetwork" "this" {
  name = var.subnetwork_name
}
