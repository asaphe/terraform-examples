data "google_client_config" "current" {}

data "template_file" "vault-values" {
  depends_on = [module.gcs_bucket]

  template = "${file("${path.module}/vault_values.tpl")}"
  vars = {
  project_name = var.project_id,
  bucket_name  = module.gcs_bucket.name,
  key_ring     = module.kms.keyring_name
  crypto_key   = var.kms_crypto_key
  ui_port      = var.vault_ui_port
  }
}

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
