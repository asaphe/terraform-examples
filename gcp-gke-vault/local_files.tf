data "template_file" "vault-values" {
  depends_on = [module.gcs_bucket]

  template = "${file("${path.module}/vault_values.tpl")}"
  vars = {
  project_name    = var.project_id,
  bucket_name     = module.gcs_bucket.name,
  key_ring        = data.google_kms_key_ring.vault.name,
  crypto_key      = data.google_kms_crypto_key.vault_key.name
  }
}

resource "local_file" "vault-values" {
  content  = data.template_file.vault-values.rendered
  filename = "${path.module}/yamls/vault_values.yaml"
}

resource "local_file" "vault-sa" {
  depends_on = [module.service_accounts.key]

  content  = module.service_accounts.key
  filename = "${path.module}/sa_credentials.json"
}
