resource "local_file" "vault-values" {
  content  = data.template_file.vault-values.rendered
  filename = "${path.module}/yamls/vault_values.yaml"
}

resource "local_file" "vault-sa" {
  depends_on = [module.service_accounts.key]

  content  = module.service_accounts.key
  filename = "${path.module}/sa_credentials.json"
}
